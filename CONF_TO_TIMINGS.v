`include "defines.vh"


// Moduł przeliczający wartości opcji modułu CONF z BCD na kod binarny
// Mnoży również wartości w jednostkach czasu przez ilość pulsów zegara przypadająćych na jednostkę
// Moduł wymaga kilku pulsów zegara
module CONF_TO_TIMINGS
(
    clk,
    ce,
    update, // rozpoczęcie obliczeń

    // Sygnały wejściowe z modułu CONF
	dit_units,
	dah_units,
	word_units,
	tol_units,
	pulses_per_unit,

    // wyznaczane sygnały wyjściowe
	dit_time,
	dah_time,
	word_time,
	tol_time,

    // Sygnalizacja zakończenia obliczeń
    ready
);


input wire clk;
input wire ce;
input wire update;

input wire [`UNIT_BCD_W*4-1 : 0] dit_units;
input wire [`UNIT_BCD_W*4-1 : 0] dah_units;
input wire [`UNIT_BCD_W*4-1 : 0] word_units;
input wire [`UNIT_BCD_W*4-1 : 0] tol_units;
input wire [`UNIT_BCD_W*4-1 : 0] pulses_per_unit;

output wire [`PULSE_CNT_W-1 : 0] dit_time;
output wire [`PULSE_CNT_W-1 : 0] dah_time;
output wire [`PULSE_CNT_W-1 : 0] word_time;
output wire [`PULSE_CNT_W-1 : 0] tol_time;

wire [`PULSE_CNT_HALF_W-1 : 0] dit_units_bin;
wire [`PULSE_CNT_HALF_W-1 : 0] dah_units_bin;
wire [`PULSE_CNT_HALF_W-1 : 0] word_units_bin;
wire [`PULSE_CNT_HALF_W-1 : 0] tol_units_bin;
wire [`PULSE_CNT_HALF_W-1 : 0] pulses_per_unit_bin;

output wire ready;

 // Zamiana każdej opcji z BCD na kod binarny
wire [4 : 0] bcds_ready;
BCD_TO_BIN bcd0 (.clk(clk), .ce(ce), .start(update), .in(dit_units),       .out(dit_units_bin),       .ready(bcds_ready[0]));
BCD_TO_BIN bcd1 (.clk(clk), .ce(ce), .start(update), .in(dah_units),       .out(dah_units_bin),       .ready(bcds_ready[1]));
BCD_TO_BIN bcd2 (.clk(clk), .ce(ce), .start(update), .in(word_units),      .out(word_units_bin),      .ready(bcds_ready[2]));
BCD_TO_BIN bcd3 (.clk(clk), .ce(ce), .start(update), .in(tol_units),       .out(tol_units_bin),       .ready(bcds_ready[3]));
BCD_TO_BIN bcd4 (.clk(clk), .ce(ce), .start(update), .in(pulses_per_unit), .out(pulses_per_unit_bin), .ready(bcds_ready[4]));

// Mnożenie każdej opcji przez pulsy zegara na jednostkę czasu
assign dit_time  = dit_units_bin  * pulses_per_unit_bin;
assign dah_time  = dah_units_bin  * pulses_per_unit_bin;
assign word_time = word_units_bin * pulses_per_unit_bin;
assign tol_time  = tol_units_bin  * pulses_per_unit_bin;

// Wyznaczanie ready
assign ready = (&bcds_ready) && (!update);

endmodule

// Modył wyznaczający kod binarny z kodu BCD
module BCD_TO_BIN
#(
    parameter DIGITS = `UNIT_BCD_W, // Liczba cyfr BCD
    parameter OUT_W  = `PULSE_CNT_HALF_W // szerokość wynikowej wartości binarnej
)(
    clk,
    ce,
    start, // Rozpoczęcie obliczeń

    in, // wejście w BCD
    out, // wyjście w kodzie binarnym
    ready // sygnalizacja zakończenia pracy

);

input clk;
input ce;
input start;

input wire [DIGITS*4-1 : 0] in;
output reg [OUT_W-1    : 0] out = 0;
output wire ready;

reg [DIGITS*4-1 : 0] in_buffer = 0; // Tymczasowa wartość BCD
reg [2:0] ops_left = 0; // Liczba kroków pozostała do wykonania
assign ready = (ops_left == 0) && !start; // wyznaczenie ready

// Obliczenia
always @(posedge clk) begin
    if(ce) begin
        if(start) begin  // rozpoczęcie nowego oblicznia
            out <= 0; // Wyzerowanie wyjścia
            in_buffer <= in; // zapisanie wejścia
            ops_left <= DIGITS; // inicjacja licznika pozostałych kroków
        end else if(ops_left != 0) begin
            out <= (out << 3) + (out << 1) + in_buffer[DIGITS*4-1 : DIGITS*4-4]; // Przemnożenie aktualnej wartości wyniku przez 10 i dodanie kolejnej cyfry
            in_buffer <= in_buffer << 4; // przesunięcie rejestru tyumczasowego wejscia do kolejnej iteracji
            ops_left <= ops_left - 1'd1; // zmniejszenie liczby pozostąłych kroków
        end
    end
end

endmodule