`include "defines.vh"

module MORSE_CAPTURE_AND_DECODE_WORD(
    clk,
    ce,

	dit_time,
	dah_time,
	word_time,
	tol_time,

    signal,

    word,
    word_ended,
    error
);

input wire clk;
input wire ce;

input wire [`PULSE_CNT_W-1 : 0] dit_time;
input wire [`PULSE_CNT_W-1 : 0] dah_time;
input wire [`PULSE_CNT_W-1 : 0] word_time;
input wire [`PULSE_CNT_W-1 : 0] tol_time;

input wire signal;

output wire [`CHAR_W*`MAX_CHARS-1 : 0] word;
output wire error;
output wire word_ended;

wire  [`MORSE_LEN_W-1   : 0] len;
wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
wire capture_error;
wire capture_ceo;
wire capture_word_end;


wire capture_start = signal & word_ended;

MORSE_CAPTURE_CHAR u_capture(
    .clk        (clk),
    .ce         (ce),
	.start      (capture_start),
	.dit_time   (dit_time),
	.dah_time   (dah_time),
	.word_time  (word_time),
	.tol_time   (tol_time),
    .signal     (signal),
    .len        (len),
    .dits_dahs  (dits_dahs),
    .error      (capture_error),
    .word_end   (capture_word_end),
	.ceo        (capture_ceo)
);

MORSE_DECODE_WORD u_decode(
    .clk        (clk),
    .ce         (capture_ceo),
    .dits_dahs  (dits_dahs),
    .len        (len),
    .word_end   (capture_word_end),
    .error_in   (capture_error),
    .word       (word),
    .word_ended (word_ended),
    .error      (error)
);


endmodule