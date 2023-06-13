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
wire signal = KEY[0];

wire [`PULSE_CNT_W-1 : 0] dit_time;
wire [`PULSE_CNT_W-1 : 0] dah_time;
wire [`PULSE_CNT_W-1 : 0] word_time;
wire [`PULSE_CNT_W-1 : 0] tol_time;
wire conf_ready;

CONF u_conf(
    .clk				(clk),
    .ce					(ce),
	.dit_time			(dit_time),
	.dah_time			(dah_time),
	.word_time			(word_time),
	.tol_time			(tol_time),
    .ready				(conf_ready)
);


wire decode_error;
wire decode_word_ended;
wire [`CHAR_W*`MAX_CHARS-1 : 0] decode_word;

MORSE_CAPTURE_AND_DECODE_WORD u_capture_and_decode(
    .clk         (clk),
    .ce          (ce & conf_ready),
	.dit_time    (dit_time),
	.dah_time    (dah_time),
	.word_time   (word_time),
	.tol_time    (tol_time),
    .signal      (signal),
    .word        (decode_word),
    .word_ended  (decode_word_ended),
    .error       (decode_error)
);

CHAR2SEG u_seg0 (decode_word >> (0 * `CHAR_W), HEX0);
CHAR2SEG u_seg1 (decode_word >> (1 * `CHAR_W), HEX1);
CHAR2SEG u_seg2 (decode_word >> (2 * `CHAR_W), HEX2);
CHAR2SEG u_seg3 (decode_word >> (3 * `CHAR_W), HEX3);
CHAR2SEG u_seg4 (decode_word >> (4 * `CHAR_W), HEX4);
CHAR2SEG u_seg5 (decode_word >> (5 * `CHAR_W), HEX5);

assign LED[0] = decode_word_ended;
assign LED[1] = conf_ready;
assign LED[2] = decode_error;

endmodule