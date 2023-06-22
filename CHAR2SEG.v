`include "defines.vh"

module CHAR2SEG(
	input blink,
	input  wire [`CHAR_W-1 : 0] char,
	output reg  [6:0] seg
);

always @(*) begin

	if (blink) 
		seg <= 7'b1111111;
	else
		case(char)
			`CHAR_CODE_0: seg <= 7'b1000000;
			`CHAR_CODE_1: seg <= 7'b1111001;
			`CHAR_CODE_2: seg <= 7'b0100100;
			`CHAR_CODE_3: seg <= 7'b0110000;
			`CHAR_CODE_4: seg <= 7'b0011001;
			`CHAR_CODE_5: seg <= 7'b0010010;
			`CHAR_CODE_6: seg <= 7'b0000010;
			`CHAR_CODE_7: seg <= 7'b1111000;
			`CHAR_CODE_8: seg <= 7'b0000000;
			`CHAR_CODE_9: seg <= 7'b0010000;
			`CHAR_CODE_A: seg <= 7'b0001000;
			`CHAR_CODE_B: seg <= 7'b0000011;
			`CHAR_CODE_C: seg <= 7'b1000110;
			`CHAR_CODE_D: seg <= 7'b0100001;
			`CHAR_CODE_E: seg <= 7'b0000110;
			`CHAR_CODE_F: seg <= 7'b0001110;
			
			`CHAR_CODE_G: seg <= 7'b1000010;
			`CHAR_CODE_H: seg <= 7'b0001001;
			`CHAR_CODE_I: seg <= 7'b1001111;
			`CHAR_CODE_J: seg <= 7'b1100001;
			`CHAR_CODE_K: seg <= 7'b0001011;
			`CHAR_CODE_L: seg <= 7'b1000111;
			`CHAR_CODE_M: seg <= 7'b1101010;
			`CHAR_CODE_N: seg <= 7'b0101011;
			`CHAR_CODE_O: seg <= 7'b0100011;
			`CHAR_CODE_P: seg <= 7'b0001100;
			`CHAR_CODE_Q: seg <= 7'b0011000;
			`CHAR_CODE_R: seg <= 7'b0101111;	
			`CHAR_CODE_S: seg <= 7'b0010010;
			`CHAR_CODE_T: seg <= 7'b0000111;
			`CHAR_CODE_U: seg <= 7'b1100011;
			`CHAR_CODE_V: seg <= 7'b1000001;
			`CHAR_CODE_W: seg <= 7'b1010101;
			`CHAR_CODE_X: seg <= 7'b0110110;
			`CHAR_CODE_Y: seg <= 7'b0011001;
			`CHAR_CODE_Z: seg <= 7'b0100100;

			default: seg <= 7'b1111111;
		endcase

end

endmodule