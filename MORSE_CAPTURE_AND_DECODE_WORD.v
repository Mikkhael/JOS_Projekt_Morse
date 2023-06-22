`include "defines.vh"

// Moduł odpowiedzialny za całą logikę związaną z dekodowaniem sygnału Morse'a
module MORSE_CAPTURE_AND_DECODE_WORD
#(
    // Pomocnicze sygnały do debugowania w symulacji
    parameter DEBUG_CAPTURE = 0,
    parameter DEBUG_DECODE = 0
)
(
    clk,
    ce,
    aclr,

    // Wartości czasów poszczególnych sygnałów Morse'a
	dit_time,
	dah_time,
	word_time,
	tol_time,

    // Wejsćiowy sygnał Morse'a
    signal,

	capture_running, // Sygnalizacja, czy aktualnie wczytywane jest nowy znak
    word, // Oktualnie wczytane słowo, jako lista kodów znaków
    word_ended, // Sygnalizacja, czy słowo jest zakończone
    error // Sygnalizacja, czy wystąpił błąd
);

input wire clk;
input wire ce;
input wire aclr;

input wire [`PULSE_CNT_W-1 : 0] dit_time;
input wire [`PULSE_CNT_W-1 : 0] dah_time;
input wire [`PULSE_CNT_W-1 : 0] word_time;
input wire [`PULSE_CNT_W-1 : 0] tol_time;

input wire signal;

output wire capture_running;
output wire [`CHAR_W*`MAX_CHARS-1 : 0] word;
output wire error;
output wire word_ended;

wire  [`MORSE_LEN_W-1   : 0] len;
wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
wire capture_error;
wire capture_ceo;
wire capture_word_end;

// Pozyskanie kolejnych znaków
MORSE_CAPTURE_CHAR#(.DEBUG(DEBUG_CAPTURE)) u_capture(
    .clk        (clk),
    .ce         (ce),
    .aclr       (aclr),
	.dit_time   (dit_time),
	.dah_time   (dah_time),
	.word_time  (word_time),
	.tol_time   (tol_time),
    .signal     (signal),
    .len        (len),
    .dits_dahs  (dits_dahs),
    .error      (capture_error),
	 .run        (capture_running),
    .word_end   (capture_word_end),
	.ceo        (capture_ceo)
);

// Dekodowanie kolejnych znaków i zapis do rejestru przesównego
MORSE_DECODE_WORD#(.DEBUG(DEBUG_DECODE)) u_decode(
    .clk        (clk),
    .ce         (capture_ceo),
    .aclr       (aclr),
    .dits_dahs  (dits_dahs),
    .len        (len),
    .word_end   (capture_word_end),
    .error_in   (capture_error),
    .word       (word),
    .word_ended (word_ended),
    .error      (error)
);


endmodule