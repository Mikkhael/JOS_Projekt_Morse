`timescale 1ps/1ps

`include "../defines.vh"

// Moduł testujący moduł MORSE_CAPTURE_CHAR
module MORSE_CAPTURE_CHAR_tb();

reg clk = 0;
reg ce = 1;
reg signal = 0;

// Przykładowe wartości timingów
reg  [`PULSE_CNT_W-1 : 0] DIT  = 10;
reg  [`PULSE_CNT_W-1 : 0] DAH  = 30;
reg  [`PULSE_CNT_W-1 : 0] WORD = 70;
reg  [`PULSE_CNT_W-1 : 0] TOL  = 5;
wire [`PULSE_CNT_W-1 : 0] CHAR_END  = DAH  + 1'd1;
wire [`PULSE_CNT_W-1 : 0] WORD_END  = WORD + 1'd1;
wire [`PULSE_CNT_W-1 : 0] SIM_TOL = TOL;

wire  [`MORSE_LEN_W-1   : 0] len;
wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
wire error;
wire word_end;
wire capture_ceo;

// Testowany moduł
MORSE_CAPTURE_CHAR#(.DEBUG(1)) u_capture(
    .clk(clk),
    .ce(ce),
	.dit_time(DIT),
	.dah_time(DAH),
	.word_time(WORD),
	.tol_time(TOL),
    .signal(signal),
    .len(len),
    .dits_dahs(dits_dahs),
    .error(error),
    .word_end(word_end),
	.ceo(capture_ceo)
);

// Oczekiwane wyjście z modułu
reg  expected_word_end = 0;
reg  [`MORSE_LEN_W-1   : 0] expected_len = 0;
reg  [`MAX_MORSE_LEN-1 : 0] expected_dits_dahs = 0;
reg is_good = 1;

// Porównanie zastanego wyjścia z oczekiwanym
always @(posedge clk) begin
    
    if(word_end & capture_ceo) begin 
        $write("WORD END ");
        if(expected_word_end)  begin
            $display("[OK]");
        end else begin
            $display("[ INVALID !!! ]");
            is_good = 0;
        end
        expected_word_end = 0;
    end
    else if(capture_ceo) begin
        $write("CHAR END: %b (len: %2d) (error: %1b) ", dits_dahs, len, error);
        if(
            !error && 
            expected_len == len &&
            expected_dits_dahs == ( dits_dahs & ((1 << len) - 1'd1) )
        ) begin
            $display("[OK]");
        end else begin
            $display("[ INVALID !!! ] - EXPECTED: %b (len: %2d)", expected_dits_dahs, expected_len);
            is_good = 0;
        end
        expected_len = 0;
        expected_dits_dahs = 0;
    end

end

initial begin
    // Inicjalizacja
    ce = 0;
    WAIT(10);
    ce = 1;

    // Podanie przykładowych sekwencji
    TEST_STR_CHAR("--.-.", 0);
    TEST_STR_CHAR("...",   0);
    TEST_STR_CHAR("---",   1);

    TEST_STR_CHAR("---.",  0);
    TEST_STR_CHAR("...-",  1);

    TEST_STR_CHAR(".-.-.", 1);

    TEST_STR_CHAR("-.-.-", 0);
    TEST_STR_CHAR(".",     0);
    TEST_STR_CHAR("-",     1);

    $display("==========================");
    $display("== TESTS SUCCESSFUL: %b ==", is_good); // Sprawedzenie, czy którykolwiek test przeszedł niepoprawnie
    $display("==========================");
    $stop;
end

`include "common_tasks.vh"

// Rozpoczęcie pojedyńczego testu (dana sekwencja znaków, + czy ma to być ostatni znak w słowie)
task automatic TEST_STR_CHAR(input [10*8-1:0] str, input end_word);
    integer i;
begin
    // Wyznaczenie oczekiwanych wartości
    {expected_dits_dahs, expected_len} = str_to_dits_dahs_len(str);
    expected_word_end = end_word;
    $display("EXPECT    %b (len: %2d) (word_end: %b)", expected_dits_dahs, expected_len, expected_word_end);
    // Wyznałnie danej sekwencji (definicja TASKU w common_tasks.vh)
    SEND_STR_CHAR(str, end_word);
    // Odczekanie 1 cyklu zegara
    WAIT(1);
end
endtask

endmodule