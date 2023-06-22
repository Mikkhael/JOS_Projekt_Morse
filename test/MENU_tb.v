`timescale 1ps/1ps
`include "../defines.vh"

// Moduł testujący moduł MENU
module MENU_tb();

reg clk    = 0;
reg ce     = 1;

// Sygnały wejsciowe przycisków
reg btn_up = 1;
reg btn_dn = 1;
reg btn_lf = 1;
reg btn_rt = 1;

// Sygnały do komunikacji z modułem CONF
wire [2:0] conf_selected_index;
wire [`UNIT_BCD_W*4-1 : 0] conf_selected_value;
wire [`UNIT_BCD_W*4-1 : 0] conf_selected_new_value;
wire conf_selected_set;
wire [`UNIT_BCD_W-1:0] blinking;
wire [`UNIT_BCD_W*`CHAR_W-1:0] menu_word;
wire conf_ready;

// Testowany moduł
MENU u_menu(
    .clk                     (clk),
    .ce                      (ce),
    .btn_up                  (btn_up),
    .btn_dn                  (btn_dn),
    .btn_lf                  (btn_lf),
    .btn_rt                  (btn_rt),
	.conf_selected_index     (conf_selected_index),
	.conf_selected_value     (conf_selected_value),
	.conf_selected_new_value (conf_selected_new_value),
	.conf_selected_set       (conf_selected_set),
    .blinking                (blinking),
    .menu_word               (menu_word)
);

// Moduł CONF, potrzebny do testów
CONF u_conf(
    .clk				(clk),
    .ce					(ce),
	.selected_index     (conf_selected_index),
	.selected_value     (conf_selected_value),
	.selected_new_value (conf_selected_new_value),
	.selected_set       (conf_selected_set),
    .ready              (conf_ready)
);

// Podgląd sygnałów wyjściowych z modułu, za każdą ich zmianą
always @(*) begin
    $display("NAME:%s CONF:[IDX:%b, VAL:%h, NEW:%h, SET:%b], BLNK:%b, RDY:%b", 
        word_to_ascii(menu_word),
        conf_selected_index,    
        conf_selected_value,    
        conf_selected_new_value,
        conf_selected_set,
        blinking,
        conf_ready
    );
end

integer i;
initial begin

    WAIT(10);

    // Symulacja naciśnięć sekwencji naciśnięć danych klawiszy
    // Tester musi prześledzić waveform i logi aby określić, czy moduł zachowuje się w oczekiwany sposób

    PRESS("U");
    PRESS("D");
    PRESS("D");
    PRESS("D");
    PRESS("U");
    PRESS("D");
    PRESS("L");
    PRESS("D");
    PRESS("R");
    for(i=0; i<12; i = i + 1) begin
        PRESS("D");
    end
    for(i=0; i<12; i = i + 1) begin
        PRESS("U");
    end
    PRESS("R");
    PRESS("R");
    PRESS("U");
    PRESS("U");
    PRESS("L");
    PRESS("U");
    PRESS("U");
    PRESS("R");
    WAIT(100);
    PRESS("L");

    $stop;
end


// Oczekiwanie liczby pulsów zegara
task automatic WAIT(input integer rep);
    integer i = 0;
begin
    for(i = 0; i < rep; i = i + 1 ) begin
        clk = 1'd1; #10;
        clk = 1'd0; #10;
    end
end
endtask

// Symuylacja naciśnięcia przycisku
task automatic PRESS(input [7:0] btn);
begin
    $display("PRESS %s", btn);
    WAIT(1);
    case(btn)
    "U": btn_up <= 0;
    "D": btn_dn <= 0;
    "L": btn_lf <= 0;
    "R": btn_rt <= 0;
    endcase
    WAIT(5);
    case(btn)
    "U": btn_up <= 1;
    "D": btn_dn <= 1;
    "L": btn_lf <= 1;
    "R": btn_rt <= 1;
    endcase
    WAIT(5);
end
endtask

// Konwersja sekwencji kodów znaków na znak wyświetlalny w konsoli symnulatora
function [9*`UNIT_BCD_W-1 : 0] word_to_ascii(input [`CHAR_W*`UNIT_BCD_W-1 : 0] word);
    integer i;
begin
    for(i=0; i<`UNIT_BCD_W; i = i + 1) begin
        word_to_ascii = word_to_ascii >> 8;
        word_to_ascii[8*`UNIT_BCD_W-1 : 8*(`UNIT_BCD_W-1)] = `CHAR_ASCI_ARRAY >> (8*(`CHARS_COUNT-1 - word[`CHAR_W-1 : 0]));
        word = word >> `CHAR_W;
    end
end
endfunction

endmodule
