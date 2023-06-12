`include "defines.vh"

module MORSE_DECODE_WORD(
    clk,
    ce,

    dits_dahs,
    len,
    word_end,
    error_in,

    word,
    word_ended,
    error
);

input wire clk;
input wire ce;

input wire [`MORSE_LEN_W-1   : 0] len;
input wire [`MAX_MORSE_LEN-1 : 0] dits_dahs;
input wire word_end;
input wire error_in;

output reg [`CHAR_W*`MAX_CHARS-1 : 0] word = {`MAX_CHARS{ `CHAR_CODE_SPACE }};
output reg word_ended = 1;
output reg error = 0;


wire [`CHAR_W-1 : 0] current_char;

MORSE_RECOGNIZE_CHAR u_recognize(
	.len(len),
	.dits_dahs(dits_dahs),
	.char(current_char)
);

always @(posedge clk) begin
    
    if(ce) begin
        if(word_end) begin
            word_ended <= 1;
        end else begin
            if(word_ended) begin
                word[`CHAR_W*`MAX_CHARS-1 : `CHAR_W] <= {(`MAX_CHARS - 1){ `CHAR_CODE_SPACE }};
            end else begin
                word[`CHAR_W*`MAX_CHARS-1 : `CHAR_W] <= word[`CHAR_W*(`MAX_CHARS-1)-1 : 0];
            end
            error <= error_in | (error & ~word_ended);
            word[`CHAR_W-1 : 0] <= current_char;
            word_ended <= word_end;
        end
    end
end



endmodule