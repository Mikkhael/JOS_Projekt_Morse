`include "defines.vh"

// Moduł odpowiedzialny z przechowywanie i wyznaczanie zkonfigurowanej liczby pulsów sygnału zegarowego,
// które odpowidają odpowiednim timingom sygnału Morse'a
// Sygnału przechowywane są w BCD, co ułatwia wprowadzanie ich wartości w MENU, a następnie konwertowane na kod binarny
module CONF(
	clk,
	ce,

	// Wartości przechowywanych wartości czasu trwania sygnałów, jako liczba jednostek czasu w BCD
	dit_units, // Długość trwania kropki oraz przerwy między kropkami i kreskami w obrębie znaku
	dah_units, // Długość trwania kreski oraz przerwy między znakami w obrębie słowa
	word_units, // Długosć trwania przerwy między słowami
	tol_units, // Tolerancja, liczba jednostek czasu o ile +- można nie trafić w powyższe sygnały
	
	// Wartość przehcowywanej wartości liczby pulsów zegara przypadających na jedną jednostkę czasu, w BCD
	pulses_per_unit,
	
	// Wyznaczone wartości powyższych czasów, jako liczba pulsów zegara a nie jednostek, w kodzie binarnym
	dit_time,
	dah_time,
	word_time,
	tol_time,

	// Sygnał określający, czy wszystkie wartości zostały wyznacznoe
	ready,

	// Sygnały do komunikacji z modułem MENU
	selected_index, // indeks wybranej opcji
	selected_value, // zwracana wartosc wybranej opcji
	selected_new_value, // nowa wartość wybranej opcji
	selected_set // nadpisanie wybranej opcji nową wartością
);


input  wire clk;
input  wire ce;
output wire ready;

// Domyślne wartości opcji
`ifdef MANUAL_DEBUG

	output reg [`UNIT_BCD_W*4-1 : 0] dit_units    = 24'h2;
	output reg [`UNIT_BCD_W*4-1 : 0] dah_units    = 24'h6;
	output reg [`UNIT_BCD_W*4-1 : 0] word_units   = 24'h14;
	output reg [`UNIT_BCD_W*4-1 : 0] tol_units    = 24'h1;

	output reg [`UNIT_BCD_W*4-1 : 0] pulses_per_unit = 24'h1;

`else
	output reg [`UNIT_BCD_W*4-1 : 0] dit_units    = 24'h1000;
	output reg [`UNIT_BCD_W*4-1 : 0] dah_units    = 24'h3000;
	output reg [`UNIT_BCD_W*4-1 : 0] word_units   = 24'h7000;
	output reg [`UNIT_BCD_W*4-1 : 0] tol_units    = 24'h0500;

	// Domyslnie 1000 units == 1 sekunda
	output reg [`UNIT_BCD_W*4-1 : 0] pulses_per_unit = 24'h50000;
`endif



output wire [`PULSE_CNT_W-1 : 0] dit_time;
output wire [`PULSE_CNT_W-1 : 0] dah_time;
output wire [`PULSE_CNT_W-1 : 0] word_time;
output wire [`PULSE_CNT_W-1 : 0] tol_time;


input wire [2:0] selected_index;
output reg [`UNIT_BCD_W*4-1 : 0] selected_value;
input wire [`UNIT_BCD_W*4-1 : 0] selected_new_value;
input wire selected_set;

reg update = 1; // Sygnał określający, czy rozpocząć liczenie wartości opcji w kodzie binarnym na nowo

// Moduł liczący wartości timingów z BCD na kod binarny
CONF_TO_TIMINGS u_conf_to_timings(
    .clk				(clk),
    .ce					(ce),
    .update				(update),
	.dit_units			(dit_units),
	.dah_units			(dah_units),
	.word_units			(word_units),
	.tol_units			(tol_units),
	.pulses_per_unit	(pulses_per_unit),
	.dit_time			(dit_time),
	.dah_time			(dah_time),
	.word_time			(word_time),
	.tol_time			(tol_time),
    .ready				(ready)
);

// Wybór wartości opcji, zależnie od indeksu
always @(*) begin
	case(selected_index)
		3'd0:    selected_value <= dit_units;
		3'd1:    selected_value <= dah_units;
		3'd2:    selected_value <= word_units;
		3'd3:    selected_value <= tol_units;
		default: selected_value <= pulses_per_unit;
	endcase
end

// Nadpisanie wartości opcji, zależnie od indeksu
always @(posedge clk) begin
	if(ce) begin
		if(selected_set) begin
			update <= 1; // Rozpoczęcie przeliczenia wartości na kod binarny
			case(selected_index)
				3'd0: dit_units       <= selected_new_value;
				3'd1: dah_units       <= selected_new_value;
				3'd2: word_units      <= selected_new_value;
				3'd3: tol_units       <= selected_new_value;
				3'd4: pulses_per_unit <= selected_new_value;
			endcase
		end else begin
			update <= 0;
		end
	end
end

endmodule