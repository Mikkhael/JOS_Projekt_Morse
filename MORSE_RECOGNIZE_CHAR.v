`include "defines.vh"

// Układ kombinacyjny, transkodujący sekwencję kropek i kresek (wraz z ich liczbą) na kod znaku wyświetlalnego
module MORSE_RECOGNIZE_CHAR(
	len, // Liczba znaczących kropek i kresek
	dits_dahs, // Kropki i kreski (1 - kreska, 0 - kropka)
	
	char // Zdekodowany kod znaku
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
		
		{`MORSE_LEN_W'd3, 5'bxx110}: char <= `CHAR_CODE_G;
		{`MORSE_LEN_W'd4, 5'bx0000}: char <= `CHAR_CODE_H;
		{`MORSE_LEN_W'd2, 5'bxxx00}: char <= `CHAR_CODE_I;
		{`MORSE_LEN_W'd4, 5'bx0111}: char <= `CHAR_CODE_J;
		{`MORSE_LEN_W'd3, 5'bxx101}: char <= `CHAR_CODE_K;
		{`MORSE_LEN_W'd4, 5'bx0100}: char <= `CHAR_CODE_L;
		{`MORSE_LEN_W'd2, 5'bxxx11}: char <= `CHAR_CODE_M;
		{`MORSE_LEN_W'd2, 5'bxxx10}: char <= `CHAR_CODE_N;
		{`MORSE_LEN_W'd3, 5'bxx111}: char <= `CHAR_CODE_O;
		{`MORSE_LEN_W'd4, 5'bx0110}: char <= `CHAR_CODE_P;
		{`MORSE_LEN_W'd4, 5'bx1101}: char <= `CHAR_CODE_Q;
		{`MORSE_LEN_W'd3, 5'bxx010}: char <= `CHAR_CODE_R;
		{`MORSE_LEN_W'd3, 5'bxx000}: char <= `CHAR_CODE_S;
		{`MORSE_LEN_W'd1, 5'bxxxx1}: char <= `CHAR_CODE_T;
		{`MORSE_LEN_W'd3, 5'bxx001}: char <= `CHAR_CODE_U;
		{`MORSE_LEN_W'd4, 5'bx0001}: char <= `CHAR_CODE_V;
		{`MORSE_LEN_W'd3, 5'bxx011}: char <= `CHAR_CODE_W;
		{`MORSE_LEN_W'd4, 5'bx1001}: char <= `CHAR_CODE_X;
		{`MORSE_LEN_W'd4, 5'bx1011}: char <= `CHAR_CODE_Y;
		{`MORSE_LEN_W'd4, 5'bx1100}: char <= `CHAR_CODE_Z;	
	
		default: char <= `CHAR_CODE__;
	
	endcase


end


endmodule