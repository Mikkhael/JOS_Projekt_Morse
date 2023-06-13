`include "defines.vh"

module MORSE_RECOGNIZE_CHAR(
	len,
	dits_dahs,
	
	char
);


input wire  [`MORSE_LEN_W-1   : 0] len;
input wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;

output reg  [`CHAR_W-1        : 0] char;


always @(*) begin

	casex({len, dits_dahs})
	
		{`MORSE_LEN_W'd2, 5'bxxx01}: char <= `CHAR_CODE_A;
		{`MORSE_LEN_W'd4, 5'bx1000}: char <= `CHAR_CODE_B;
		{`MORSE_LEN_W'd4, 5'bx1010}: char <= `CHAR_CODE_C;
		{`MORSE_LEN_W'd3, 5'bxx100}: char <= `CHAR_CODE_D;
		{`MORSE_LEN_W'd1, 5'bxxxx0}: char <= `CHAR_CODE_E;
		{`MORSE_LEN_W'd4, 5'bx0010}: char <= `CHAR_CODE_F;
	
	
		default: char <= `CHAR_CODE_SPACE;
	
	endcase


end


endmodule