`include "defines.vh"

module MAIN(
	input clk50,
	input [9:0] SW,
	input [3:0] KEY,
	
	output [9:0] LED,
	
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5
);



wire clk    = clk50;
wire ce     = SW[0];

wire enable_morse = SW[1];
wire signal = KEY[1];

wire btn_rt = KEY[0];
wire btn_up = KEY[1];
wire btn_dn = KEY[2];
wire btn_lf = KEY[3];

wire [`PULSE_CNT_W-1 : 0] dit_time;
wire [`PULSE_CNT_W-1 : 0] dah_time;
wire [`PULSE_CNT_W-1 : 0] word_time;
wire [`PULSE_CNT_W-1 : 0] tol_time;
wire conf_ready;

wire [`UNIT_BCD_W*4-1 : 0] conf_selected_value;
wire [`UNIT_BCD_W*4-1 : 0] conf_selected_new_value;
wire [2:0] conf_selected_index;
wire conf_selected_set;

CONF u_conf(
    .clk				(clk),
    .ce					(ce),
	.dit_time			(dit_time),
	.dah_time			(dah_time),
	.word_time			(word_time),
	.tol_time			(tol_time),
    .ready				(conf_ready),
	.selected_index     (conf_selected_index),
	.selected_value     (conf_selected_value),
	.selected_new_value (conf_selected_new_value),
	.selected_set       (conf_selected_set)
);

wire [`UNIT_BCD_W-1:0] blinking;
wire [`UNIT_BCD_W*`CHAR_W-1:0] menu_word;

MENU u_menu(
    .clk                     (clk),
    .ce                      (ce),
    .btn_up                  (btn_up),
    .btn_dn                  (btn_dn),
    .btn_lf                  (btn_lf),
    .btn_rt                  (btn_rt),
	.conf_selected_index     (conf_selected_index),
	.conf_selected_value     (conf_selected_value),
	.conf_selected_new_value (conf_selected_new_value),
	.conf_selected_set       (conf_selected_set),
    .blinking                (blinking),
    .menu_word               (menu_word)
);

wire decode_error;
wire decode_word_ended;
wire [`CHAR_W*`MAX_CHARS-1 : 0] decode_word;

// TODO enable reseting when not in enable_morse mode
MORSE_CAPTURE_AND_DECODE_WORD u_capture_and_decode(
    .clk         (clk),
    .ce          (ce & conf_ready & enable_morse),
	.dit_time    (dit_time),
	.dah_time    (dah_time),
	.word_time   (word_time),
	.tol_time    (tol_time),
    .signal      (signal),
    .word        (decode_word),
    .word_ended  (decode_word_ended),
    .error       (decode_error)
);


wire [`UNIT_BCD_W*`CHAR_W-1 : 0] word_to_show = enable_morse ? decode_word : menu_word;

CHAR2SEG u_seg0 (word_to_show >> (0 * `CHAR_W), HEX0);
CHAR2SEG u_seg1 (word_to_show >> (1 * `CHAR_W), HEX1);
CHAR2SEG u_seg2 (word_to_show >> (2 * `CHAR_W), HEX2);
CHAR2SEG u_seg3 (word_to_show >> (3 * `CHAR_W), HEX3);
CHAR2SEG u_seg4 (word_to_show >> (4 * `CHAR_W), HEX4);
CHAR2SEG u_seg5 (word_to_show >> (5 * `CHAR_W), HEX5);

assign LED[0] = decode_word_ended;
assign LED[1] = conf_ready;
assign LED[2] = decode_error;
assign LED[3] = enable_morse;

endmodule