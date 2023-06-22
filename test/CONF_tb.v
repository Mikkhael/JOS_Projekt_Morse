`timescale 1ps/1ps
`include "../defines.vh"

// Moduł testujący moduł CONF oraz CONF_TO_TIMINGS
module CONF_tb();

reg clk    = 0;
reg ce     = 1;
reg update = 1;

// Przykłądowe sygnały wejściowe do modułu CONF_TO_TIMINGS
reg [`UNIT_BCD_W*4-1 : 0] dit_units       = 24'h10;
reg [`UNIT_BCD_W*4-1 : 0] dah_units       = 24'h30;
reg [`UNIT_BCD_W*4-1 : 0] word_units      = 24'h70;
reg [`UNIT_BCD_W*4-1 : 0] tol_units       = 24'h5;
reg [`UNIT_BCD_W*4-1 : 0] pulses_per_unit = 24'h100;

// Sygnały przechowywane w module CONF
wire [`UNIT_BCD_W*4-1 : 0] dit_units2;
wire [`UNIT_BCD_W*4-1 : 0] dah_units2;
wire [`UNIT_BCD_W*4-1 : 0] word_units2;
wire [`UNIT_BCD_W*4-1 : 0] tol_units2;
wire [`UNIT_BCD_W*4-1 : 0] pulses_per_unit2;

// Sygnały zwracane z modułu CONF_TO_TIMINGS
wire [`PULSE_CNT_W-1 : 0] dit_time;
wire [`PULSE_CNT_W-1 : 0] dah_time;
wire [`PULSE_CNT_W-1 : 0] word_time;
wire [`PULSE_CNT_W-1 : 0] tol_time;
wire conf_tim_ready;

// Sygnały zwracane z modułu CONF
wire [`PULSE_CNT_W-1 : 0] dit_time2;
wire [`PULSE_CNT_W-1 : 0] dah_time2;
wire [`PULSE_CNT_W-1 : 0] word_time2;
wire [`PULSE_CNT_W-1 : 0] tol_time2;
wire conf_ready;

// Sygnały do komunikacji z modułem MENU
reg  [2:0] selected_index = 0;
wire [`UNIT_BCD_W*4-1 : 0] selected_value;
reg  [`UNIT_BCD_W*4-1 : 0] selected_new_value = 0;
reg  selected_set = 0;

// Instancje testowanych modułów
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
    .ready				(conf_tim_ready)
);

CONF u_conf(
    .clk				(clk),
    .ce					(ce),
	.dit_time			(dit_time2),
	.dah_time			(dah_time2),
	.word_time			(word_time2),
	.tol_time			(tol_time2),
	.dit_units			(dit_units2),
	.dah_units			(dah_units2),
	.word_units			(word_units2),
	.tol_units			(tol_units2),
	.pulses_per_unit	(pulses_per_unit2),
    .ready				(conf_ready),
	.selected_index     (selected_index),
	.selected_value     (selected_value),
	.selected_new_value (selected_new_value),
	.selected_set       (selected_set)
);

// Podgląd wartości zwracanej przez moduł CONF
always @(selected_value) begin
    $display("CHANGED SELECTED VAL: %2d, %h", selected_index, selected_new_value);
end

reg timeout = 0;
integer reps = 0;

initial begin

    // INICJACJA
    update = 1;
    WAIT(2);
    update = 0;
    WAIT(2);

    // Oczekiwanie, aż czasy zostaną wyznaczone 
    AWAIT_CONF_TIM_READY(100, reps, timeout);
    // Testowanie modułów zamiany BCD na kod binarny
    TEST_BCD(24'h123456 , 24'h1, 20'd123456);
    TEST_BCD(dit_units  , pulses_per_unit, dit_time);
    TEST_BCD(dah_units  , pulses_per_unit, dah_time);
    TEST_BCD(word_units , pulses_per_unit, word_time);
    TEST_BCD(tol_units  , pulses_per_unit, tol_time);

    // Symulacja sygnałów z modułu MENU, ustawienie nowych wartośći opcji w CONF
    SET_CONF(0, 24'h123456);
    SET_CONF(1, 24'h234561);
    SET_CONF(2, 24'h345645);
    SET_CONF(3, 24'h456789);
    SET_CONF(4, 24'h567890);

    // Oczekiwanie, aż czasy zostaną wyznaczone 
    AWAIT_CONF_TIM_READY(100, reps, timeout);
    // Testowanie, czy sygnały zostały poprawnie wyznaczone
    TEST_BCD(dit_units2  , pulses_per_unit2, dit_time2);
    TEST_BCD(dah_units2  , pulses_per_unit2, dah_time2);
    TEST_BCD(word_units2 , pulses_per_unit2, word_time2);
    TEST_BCD(tol_units2  , pulses_per_unit2, tol_time2);


    $stop;

end

// Odczekanie danej liczby pulsów zegara
task automatic WAIT(input integer rep);
    integer i = 0;
begin
    for(i = 0; i < rep; i = i + 1 ) begin
        clk = 1'd1; #10;
        clk = 1'd0; #10;
    end
end
endtask

// Ustawienie opcji o indeksie "index" na wartosc "val" w CONF (symulacja działania modułu MENU)
task automatic SET_CONF(input integer index, input [`UNIT_BCD_W*4-1 : 0] val);
begin
    $display("SETTING CONF %d to %h", index, val);
    selected_index = index;
    selected_new_value = val;
    WAIT(1);
    selected_set = 1;
    WAIT(1);
    selected_set = 0;
end
endtask

// Wyznaczenie wartości kodu binarnego iloczynu dwóch liczb w kodzie BCD, i porównanie go z oczekiwanym
task automatic TEST_BCD(input [`UNIT_BCD_W*4-1 : 0] bcd1, input [`UNIT_BCD_W*4-1 : 0] bcd2, input [`PULSE_CNT_W-1 : 0] bin);
    reg [`PULSE_CNT_W-1 : 0] converted1;
    reg [`PULSE_CNT_W-1 : 0] converted2;
    reg [`PULSE_CNT_W-1 : 0] converted;
begin
    converted1 = bcd_to_bin(bcd1);
    converted2 = bcd_to_bin(bcd2);
    converted = converted1 * converted2;
    $write("COMPARE BCD TO BIN: %h * %h = %d | %d ", bcd1, bcd2, converted, bin);
    if( converted == bin ) begin
        $display( "[ OK! ]" );
    end else begin
        $display( "[ INVALID !!! ]" );
    end
end
endtask

// Oczekiwanie na sygnał ready (z timeoutem)
task automatic AWAIT_CONF_TIM_READY(input integer max_reps, output waited_reps, output timeout);
    integer reps;
begin
    reps = 0;
    while((!conf_tim_ready || !conf_ready) && reps < max_reps) begin
        WAIT(1);
        reps = reps + 1;
    end
    waited_reps = reps;
    timeout = (!conf_tim_ready || !conf_ready);
    if(timeout) begin
        $display("TIMEDOUT");
    end else begin
        $display("AWAITED CYCLES: %d", reps);
    end
end
endtask

// Programistyczne wyznaczenie kodu binarnego z kodu BCD
function automatic [`PULSE_CNT_HALF_W-1 : 0] bcd_to_bin(input [2*`UNIT_BCD_W*4-1 : 0] bcd);
    integer i;
    integer pow;
begin
    bcd_to_bin = 0;
    pow = 1;
    for(i = 0; i<`UNIT_BCD_W*2; i = i + 1) begin
        bcd_to_bin = bcd_to_bin + bcd[3:0]*pow;
        bcd = bcd >> 4;
        pow = pow * 10;
    end
end
endfunction

endmodule