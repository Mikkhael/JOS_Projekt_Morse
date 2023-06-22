`include "defines.vh"

// Moduł zamieniający kolejne znaki, złożone z kropek i kresek, na kody znaków drukowalnych, i dodający je do rejestru słowa
module MORSE_DECODE_WORD
#(
    parameter DEBUG = 0
)
(
    clk,
    ce,
    aclr,

    dits_dahs, // wartości kresek i kropek (1 - kreska, 0 - kropka)
    len, // Liczba ważnych bitów sygnału dits_dahs (liczba kresek i kropek)
    word_end, // Czy napotkano koniec słowa
    error_in, // Czy napotkano bląd w module zbierającym kropki i kreski

    word, // Zdekodowane słowo
    word_ended, // Czy zakończono wczytywanie całego słowa
    error // Czy napotkano błąd podczas dekodowania danego słowa
);

input wire clk;
input wire ce;
input wire aclr;

input wire [`MORSE_LEN_W-1   : 0] len;
input wire [`MAX_MORSE_LEN-1 : 0] dits_dahs;
input wire word_end;
input wire error_in;

output reg [`CHAR_W*`MAX_CHARS-1 : 0] word = {`MAX_CHARS{ `CHAR_CODE__ }}; // Inicjalizacja słowa samymi spacjami
output reg word_ended = 1;
output reg error = 0;

wire [`CHAR_W-1 : 0] current_char;

// Zamiana kropek i kresek na kod znaku
MORSE_RECOGNIZE_CHAR u_recognize(
	.len(len),
	.dits_dahs(dits_dahs),
	.char(current_char)
);

always @(posedge clk) begin
    
    if(aclr) begin // Zerpwamoa
        word <= {`MAX_CHARS{ `CHAR_CODE__ }}; // Wpisanie samych spacji
        word_ended <= 1;
        error <= 0;
    end
    else if(ce) begin
        if(word_end) begin // Czy napotkano koniec słowa
            if(DEBUG) $display("   ENDING DECODE");
            word_ended <= 1; // Sygnalizuj koniec słowa
        end else begin
            if(word_ended) begin // Czy poprzednie słowo zakończyło wczytywanie
                if(DEBUG) $display("== STARTING DECODE =============="); 
                word[`CHAR_W*`MAX_CHARS-1 : `CHAR_W] <= {(`MAX_CHARS - 1){ `CHAR_CODE__ }}; // Jeśli tak, to rozpoczęcie nowego słowa (wypełnienie spacjami)
            end else begin
                word[`CHAR_W*`MAX_CHARS-1 : `CHAR_W] <= word[`CHAR_W*(`MAX_CHARS-1)-1 : 0]; // Zshifrowanie słowa o jeden znak w lewo
            end
            if(DEBUG) $display("   DECODING CHAR (%b[%2d] -> %2d), err=%b, end=%b", dits_dahs, len, current_char, error, word_end);
            error <= error_in | (error & ~word_ended); // Wyznaczenie błędu
            word[`CHAR_W-1 : 0] <= current_char; // Dodanie nowego znaku do słowa
            word_ended <= word_end; // Wyznaczenie, czy słowo się zakończyło
        end
    end
end



endmodule