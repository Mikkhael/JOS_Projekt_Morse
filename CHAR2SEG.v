`include "defines.vh"

module CHAR2SEG(
	input  wire [`CHAR_W-1 : 0] char,
	output reg  [6:0] seg
);


always @(*) begin

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

		default: seg <= 7'b1111111;
	endcase

end

endmodule