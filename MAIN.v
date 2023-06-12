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



wire dit_units;
wire dah_units;
wire pause_units;
wire char_units;
wire word_units;
wire tol_units;
wire pulses_per_unit;

CONF u_conf(
	.dit_units( dit_units ),
    .dah_units( dah_units ),
    .pause_units( pause_units ),
    .char_units( char_units ),
    .word_units( word_units ),
    .tol_units( tol_units ),
    .pulses_per_unit( pulses_per_unit )
);

wire  [`MORSE_LEN_W-1   : 0] len;
wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
wire  [`CHAR_W-1        : 0] char;

wire error;
wire char_end;
wire word_end;
wire capture_ceo;

MORSE_CAPTURE_CHAR u_capture(
    .clk(~KEY[0]),
    .ce(SW[0]),
	.start(~KEY[3]),
	.dit_time(40'd10),
	.dah_time(40'd30),
	.word_time(40'd70),
	.tol_time(40'd5),
    .signal(~KEY[1]),
    .len(len),
    .dits_dahs(dits_dahs),
    .error(error),
    .word_end(word_end),
	.ceo(capture_ceo)
);

MORSE_RECOGNIZE_CHAR u_recognize(
	.len(len),
	.dits_dahs(dits_dahs),
	.char(char)
);

//CHAR2SEG seg0 (units_cnt[3:0], HEX0);
//CHAR2SEG seg1 (units_cnt[7:4], HEX1);
CHAR2SEG seg2 (char, HEX2);
CHAR2SEG seg3 (len, HEX3);
CHAR2SEG seg4 (`CHAR_CODE_SPACE, HEX4);
CHAR2SEG seg5 (`CHAR_CODE_SPACE, HEX5);

assign LED[0] = char_end;
assign LED[1] = word_end;
assign LED[2] = error;

assign LED[9:5] = dits_dahs;



//assign len = SW[9:7];
//assign dits_dahs = SW[4:0];
//
//MORSE_RECOGNIZE_CHAR u1(
//	.len(len),
//	.dits_dahs(dits_dahs),
//	.char(char)
//);

//CHAR2SEG seg0 (char, HEX0);



endmodule