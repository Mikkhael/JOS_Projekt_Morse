`include "defines.vh"

// Moduł przetwarzający sygnał Morse'a na listę kropek i kresek
module MORSE_CAPTURE_CHAR
#(
    parameter DEBUG = 0
)
(
    clk,
    ce,
    aclr,

    // Konfiguracja z modułu CONF
	dit_time,
	dah_time,
	word_time,
	tol_time,

    // Sygnał wejściowy
    signal,

    len, // liczba kropek i kresek odebranego znaku
    dits_dahs, // kropki i kreski odebranego znaku (bit 1 symbolizuje kreskę, a 0 kropkę)
    error, // Sygnalizacja, czy wystąpił nieoczekiwany bład

	run, // Sygnalizacja, czy moduł aktualnie wczytuje nowy znak
    word_end, // sygnalizacja napotkania końca słowa
    ceo // Clock Enable Output (włączany po odebraniu całego znaku lub słowa)

);

input wire clk;
input wire ce;
input wire aclr;

input wire [`PULSE_CNT_W-1 : 0] dit_time;
input wire [`PULSE_CNT_W-1 : 0] dah_time;
input wire [`PULSE_CNT_W-1 : 0] word_time;
input wire [`PULSE_CNT_W-1 : 0] tol_time;

input wire signal;

output reg [`MORSE_LEN_W-1   : 0] len = 0;
output reg [`MAX_MORSE_LEN-1 : 0] dits_dahs = 0;
output reg error = 0;

output reg run = 0;
output reg word_end = 0;
output wire ceo;

// Wyznaczeni zbocza sygnałów sygnalizujących zakończenie odczytywanuia znaku lub słowa
reg char_end = 0;
reg last_char_end = 0;
reg last_word_end = 0;
// Wyznaczenie ceo
assign ceo = ce & (
    char_end & (~last_char_end) |
    word_end & (~last_word_end)
);

// Zapamiętywanie poprzedniej wartości sygnału wejściowego
reg last_signal = 0;

// Licznik pulsów zegara przypadających na aktualnue odczytywaną kropkę, kreskę itd.
wire [`PULSE_CNT_W-1 : 0] pulse_cnt;
wire signal_changed = last_signal ^ signal;
COUNTER #(.W(`PULSE_CNT_W), .SCLR_VAL(1'd1)) u_pulse_counter(
    .clk  (clk),
    .ce   (ce & (run | signal_changed)), // Zerowania licznika przy zmianie stanu sygnału
    .sclr (signal_changed),
    .cnt  (pulse_cnt)
);

// Task dodający nową kropkę lub kreskę do odczytanego znaku
task add_char(input new_dit_dah); 
begin
    if(DEBUG) $display("ADDING DIT_DAH %b", new_dit_dah);
    if(len == `MAX_MORSE_LEN) begin // Jeśli znak jest za długi, zwróc error
        error <= 1'd1;
        if(DEBUG) $display("ERROR - CHAR TO LONG");
    end
    len <= len + 1'd1; // zwiększenie długosci znaku
    dits_dahs <= {dits_dahs[`MAX_MORSE_LEN-2:0], new_dit_dah}; // Zshiftowanie nowej kropki lub kreski
end
endtask


// Wyznaczenie thresholdów liczby pulsów zegara dla konkretnych rodzaji sygnałów
wire [`PULSE_CNT_W-1 : 0] maximal_dit_time  = dit_time[`PULSE_CNT_W-1 : 1] + dah_time[`PULSE_CNT_W-1 : 1];
wire [`PULSE_CNT_W-1 : 0] maximal_dah_time  = dah_time  + tol_time;
wire [`PULSE_CNT_W-1 : 0] minimal_char_time = dah_time  - tol_time;
wire [`PULSE_CNT_W-1 : 0] minimal_word_time = word_time - tol_time;

always @(posedge clk) begin
    
    if(aclr) begin // Zerowanie
        char_end <= 0;
        word_end <= 0;
        run <= 0;
        last_signal <= 0;
        error <= 0;
        len <= 0;
    end
    else if(ce) begin
        case({last_signal, signal}) // Różne zachowanie, zależnie od stanu aktualnego i porzedniego sygnału wejsciowego
        2'b00: begin
            if (pulse_cnt >= minimal_char_time && run) begin
                char_end <= 1; // Koniec znaku, jeśłi trwał odpowiedio długo
            end
            if (pulse_cnt >= minimal_word_time && run) begin
                if(DEBUG) $display("CAPTURE LAST - %b[%2d], err=%b, (%d)", dits_dahs, len, error, pulse_cnt);
                word_end <= 1; // Koniec słowa, jeśłi trwał odpowiedio długo
                run <= 0; // Zakończenie zliczania
            end
        end
        2'b01: begin // Rozpoczęcie nowej kreski lub kropki
            // if(DEBUG) $display("CAPTURE 01 - %d (word_end=%b, char_end=%b)", pulse_cnt, word_end, char_end);
            char_end <= 0;
            word_end <= 0;
            if(!run) begin // Jeżeli jeszcze nie rozpoczęto zliczania
                if(DEBUG) $display("CAPTURE STARTING");
                run <= 1; // Rozpoczęcie zliczania
                len <= 0; // Wyzerowanie wyjścia
                error <= 0;
            end else if(char_end || word_end) begin // Jeżeli sygnał 0 przed wejściem w ten stan trwał tylko 1 puls zegara, i wystąpił akrutat koniec znaku, ro rozpoczęcie nowego znaku
                if(DEBUG) $display("CAPTURE CHAR - %b[%2d], err=%b, (%d)", dits_dahs, len, error, pulse_cnt);
                len <= 0;
            end
        end
        2'b11: begin
            if( pulse_cnt > minimal_word_time && run) begin // Jeśli sygnał trwa zbyt długo
                if(DEBUG) $display("CAPTURE PULSE TOO LONG (%d)", pulse_cnt);
                run <= 1'd0; // Wyłącz zliczanie, by uchornić się przed przepełnieniem
                error <= 1'd1; // zwróc błąd
                // word_end <= 1'd1;
            end
        end
        2'b10: begin
            // $display("CAPTURE 10 - %d", pulse_cnt);
            run <= 1;
            if ( pulse_cnt > maximal_dit_time ) begin // Czy sygnał trwał dłużej niż maksymalna dopuszczalna długość kropki
                add_char(1); // Dodaj kreskę
            end else begin
                add_char(0); // Dodaj kropkę
            end
        end
        endcase
        // Zapisanie aktualnych wartości sygnałów do kolejnego cyklu
        last_signal <= signal;
        last_char_end <= char_end;
        last_word_end <= word_end;
    end
    

end



endmodule