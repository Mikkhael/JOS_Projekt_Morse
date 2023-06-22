`timescale 1ps/1ps

`include "../defines.vh"

// Moduł testujący moduł MORSE_CAPTURE_AND_DECODE_WORD
module MORSE_CAPTURE_AND_DECODE_WORD_tb();

reg clk = 0;
reg ce = 0;
reg signal = 0;

// Przykładowe wartości timingów
reg  [`PULSE_CNT_W-1 : 0] DIT  = 2;
reg  [`PULSE_CNT_W-1 : 0] DAH  = 6;
reg  [`PULSE_CNT_W-1 : 0] WORD = 14;
reg  [`PULSE_CNT_W-1 : 0] TOL  = 1;
wire [`PULSE_CNT_W-1 : 0] CHAR_END  = DAH  + 1'd1;
wire [`PULSE_CNT_W-1 : 0] WORD_END  = WORD + 1'd1;
wire [`PULSE_CNT_W-1 : 0] SIM_TOL = TOL;

wire error;
wire word_ended;
wire [`CHAR_W*`MAX_CHARS-1 : 0] word;

// Oczekiwane wyjście z modułu
reg [8*`MAX_CHARS-1 : 0] expected_word = 0;
reg expect_error = 0;

// Testowany moduł
MORSE_CAPTURE_AND_DECODE_WORD#(
    .DEBUG_CAPTURE(1),
    .DEBUG_DECODE(1)
) u_capture_and_decode(
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

// Wyświetlenie aktualnego zwracanego słowa, przy każdej jego zmianie
always @(word) begin
    $display("   WORD: %s (%2d,%2d,%2d,%2d,%2d,%2d) (err=%b)", word_to_ascii(word),
         word[`CHAR_W-1+`CHAR_W*5 : `CHAR_W*5],
         word[`CHAR_W-1+`CHAR_W*4 : `CHAR_W*4],
         word[`CHAR_W-1+`CHAR_W*3 : `CHAR_W*3],
         word[`CHAR_W-1+`CHAR_W*2 : `CHAR_W*2],
         word[`CHAR_W-1+`CHAR_W*1 : `CHAR_W*1],
         word[`CHAR_W-1+`CHAR_W*0 : `CHAR_W*0],
         error
    );
end

// Porównanie wyjścia otrzymanego z oczekiwanym
reg is_good = 1;
always @(posedge word_ended) begin
    $display("   END:  %s", word_to_ascii(word));
    if(expected_word != 0) begin
        if(word_to_ascii(word) == expected_word) begin
            if(error == expect_error) begin
                $display(" [TEST OK!]");
            end else begin
                $display(" [TEST EXPECTED DIFFERENT ERROR !!!] (%b)", expect_error);
                is_good = 0;
            end
        end else begin
            $display(" [TEST INVALID WORD RECEIVED !!!]");
            $display("   EXP:  %s", expected_word);
            is_good = 0;
        end
    end
end



initial begin
    ce = 0;
    WAIT(10);
    ce = 1;

    // Wysłanie kolejnych sekwencji znaków
    expected_word = "     A";
    SEND_STR_CHAR(`CHAR_MORSE_A, 1);
    WAIT(1);
    expected_word = "     B";
    SEND_STR_CHAR(`CHAR_MORSE_B, 1);
    WAIT(1);
    expected_word = "     C";
    SEND_STR_CHAR(`CHAR_MORSE_C, 1);
    WAIT(1);
    expected_word = "     D";
    SEND_STR_CHAR(`CHAR_MORSE_D, 1);
    WAIT(1);
    expected_word = "     E";
    SEND_STR_CHAR(`CHAR_MORSE_E, 1);
    WAIT(1);
    expected_word = "     F";
    SEND_STR_CHAR(`CHAR_MORSE_F, 1);
    WAIT(1);
    
    expected_word = "   ABC";
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_B, 0);
    SEND_STR_CHAR(`CHAR_MORSE_C, 1);
    WAIT(1);
    
    expected_word = "   DEF";
    SEND_STR_CHAR(`CHAR_MORSE_D, 0);
    SEND_STR_CHAR(`CHAR_MORSE_E, 0);
    SEND_STR_CHAR(`CHAR_MORSE_F, 1);
    WAIT(1);
    
    expected_word = "ABBCCC";
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_B, 0);
    SEND_STR_CHAR(`CHAR_MORSE_B, 0);
    SEND_STR_CHAR(`CHAR_MORSE_C, 0);
    SEND_STR_CHAR(`CHAR_MORSE_C, 0);
    SEND_STR_CHAR(`CHAR_MORSE_C, 1);
    WAIT(1);
    
    expected_word  = "  ABCD";
    expect_error = 1;
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_B, 0);
    SEND_SIGNAL(1, 3*WORD_END); // Symulacja za długiego dopuszczalnego sygnału wejściowego
    SEND_STR_CHAR(`CHAR_MORSE_C, 0);
    SEND_STR_CHAR(`CHAR_MORSE_D, 1);
    WAIT(1);
    
    expected_word  = "  ABCD";
    expect_error = 0;
    SEND_STR_CHAR(`CHAR_MORSE_A, 0);
    SEND_STR_CHAR(`CHAR_MORSE_B, 0);
    SEND_STR_CHAR(`CHAR_MORSE_C, 0);
    SEND_STR_CHAR(`CHAR_MORSE_D, 1);
    WAIT(1);

    $display("==========================");
    $display("== TESTS SUCCESSFUL: %b ==", is_good);
    $display("==========================");
    $stop;
end

`include "common_tasks.vh"


endmodule