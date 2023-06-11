`timescale 1ps/1ps

`include "../defines.vh"
`include "common.vh"

module MORSE_CAPTURE_CHAR_tb();

reg clk = 0;
reg ce = 1;
reg start = 0;
reg signal = 0;

reg [`PULSE_CNT_W-1 : 0] dit_time = 10;
reg [`PULSE_CNT_W-1 : 0] dah_time = 30;
reg [`PULSE_CNT_W-1 : 0] word_time = 70;
reg [`PULSE_CNT_W-1 : 0] tol_time = 5;


wire  [`MORSE_LEN_W-1   : 0] len;
wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
wire error;
wire char_end;
wire word_end;
wire capture_ceo;

MORSE_CAPTURE_CHAR u_capture(
    .clk(clk),
    .ce(ce),
	.start(start),
	.dit_time(dit_time),
	.dah_time(dah_time),
	.word_time(word_time),
	.tol_time(tol_time),
    .signal(signal),
    .len(len),
    .dits_dahs(dits_dahs),
    .error(error),
    .char_end(char_end),
    .word_end(word_end),
	.ceo(capture_ceo)
);

initial begin
    ce = 0;
    WAIT(10, clk);
    ce = 1;
    #10;

    signal = 1;
    start = 1;
    WAIT(1, clk);
    start = 0;
    WAIT(10, clk);
    signal = 1;
    WAIT(10, clk);
    signal = 0;
    WAIT(10, clk);
    signal = 1;
    WAIT(10, clk);
    signal = 0;
    WAIT(100, clk);
end

endmodule