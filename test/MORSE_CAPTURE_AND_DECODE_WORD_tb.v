`timescale 1ps/1ps

`include "../defines.vh"

module MORSE_CAPTURE_AND_DECODE_WORD_tb();

reg clk = 0;
reg ce = 0;
reg signal = 0;

reg  [`PULSE_CNT_W-1 : 0] DIT  = 10;
reg  [`PULSE_CNT_W-1 : 0] DAH  = 30;
reg  [`PULSE_CNT_W-1 : 0] WORD = 70;
reg  [`PULSE_CNT_W-1 : 0] TOL  = 5;
wire [`PULSE_CNT_W-1 : 0] CHAR_END  = DAH  + 1'd1;
wire [`PULSE_CNT_W-1 : 0] WORD_END  = WORD + 1'd1;
wire [`PULSE_CNT_W-1 : 0] SIM_TOL = TOL;

wire error;
wire word_ended;
wire [`CHAR_W*`MAX_CHARS-1 : 0] word;

MORSE_CAPTURE_AND_DECODE_WORD u_capture_and_decode(
    .clk         (clk),
    .ce          (ce),
	.dit_time    (DIT),
	.dah_time    (DAH),
	.word_time   (WORD),
	.tol_time    (TOL),
    .signal      (signal),
    .word        (word),
    .word_ended  (word_ended),
    .error       (error)
);


always @(word) begin
    $display("WORD: %s", word_to_ascii(word));
end

initial begin
    ce = 0;
    WAIT(10);
    ce = 1;

    SEND_STR_CHAR(`CHAR_MORSE_A, 1);
    SEND_STR_CHAR(`CHAR_MORSE_B, 1);
    SEND_STR_CHAR(`CHAR_MORSE_C, 1);
    SEND_STR_CHAR(`CHAR_MORSE_D, 1);
    SEND_STR_CHAR(`CHAR_MORSE_E, 1);
    SEND_STR_CHAR(`CHAR_MORSE_F, 1);
    
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_B, 0);
    SEND_STR_CHAR(`CHAR_MORSE_C, 1);
    SEND_STR_CHAR(`CHAR_MORSE_D, 0);
    SEND_STR_CHAR(`CHAR_MORSE_E, 0);
    SEND_STR_CHAR(`CHAR_MORSE_F, 1);

    $stop;
end

`include "common_tasks.vh"

endmodule