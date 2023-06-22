`include "defines.vh"

// Moduł Top-Level projektu. Kolejne sygnału odpowiadają sygnałom I/O płytki FPGA
module MAIN(
	input clk50,
	input [9:0] SW,
	input [3:0] KEY,
	
	output [9:0] LED,
	
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5
);


// Przypisanie wejść do odpowiednich sygnałów wewnętrznych
wire clk    = clk50; // Zegar
wire ce     = SW[9]; // Clocl Enable całego projektu
wire enable_morse = SW[0]; // Przełączanie między trybem MENU i detekcją kodu Morse'a
wire signal = ~(KEY[0]); // Wejście sygnału Morse'a

// Przyciski do poruszania się po MENU
wire btn_rt = KEY[0];
wire btn_up = KEY[1];
wire btn_dn = KEY[2];
wire btn_lf = KEY[3];

// Sygnały LED'ów sygnalizujących stan urządzenia
wire LED_Error;
wire LED_Running;
wire LED_Signal;
wire LED_Morse;
wire LED_Ready;
wire LED_WordEnded;

assign LED[9] = LED_Error;
assign LED[8] = LED_WordEnded;
assign LED[5] = LED_Signal;
assign LED[2] = LED_Running;
assign LED[1] = LED_Morse;
assign LED[0] = LED_Ready;

// Sygnały do połączenia z modułem Konfiguracji
wire [`PULSE_CNT_W-1 : 0] dit_time;
wire [`PULSE_CNT_W-1 : 0] dah_time;
wire [`PULSE_CNT_W-1 : 0] word_time;
wire [`PULSE_CNT_W-1 : 0] tol_time;
wire conf_ready;
wire [`UNIT_BCD_W*4-1 : 0] conf_selected_value;
wire [`UNIT_BCD_W*4-1 : 0] conf_selected_new_value;
wire [2:0] conf_selected_index;
wire conf_selected_set;

CONF u_conf(
    .clk				(clk),
    .ce					(ce & (~enable_morse)), // Konfiguracja może się zmieniać jedynie, jeśłi jesteśmy w trybie Morse'a
	.dit_time			(dit_time),
	.dah_time			(dah_time),
	.word_time			(word_time),
	.tol_time			(tol_time),
    .ready				(conf_ready),
	.selected_index     (conf_selected_index),
	.selected_value     (conf_selected_value),
	.selected_new_value (conf_selected_new_value),
	.selected_set       (conf_selected_set)
);

// Sygnały do połączenia z modułem MENU
wire [`UNIT_BCD_W-1:0] blinking;
wire [`UNIT_BCD_W*`CHAR_W-1:0] menu_word;
MENU u_menu(
    .clk                     (clk),
    .ce                      (ce & ~enable_morse), // Poruszać się po MENU można jedynie, kiedy nie jesteśmy w trybie Morse'a
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


// Sygnały do połączenia z modułem detekcji Morse'a
wire decode_error;
wire capture_running;
wire decode_word_ended;
wire [`CHAR_W*`MAX_CHARS-1 : 0] decode_word;

MORSE_CAPTURE_AND_DECODE_WORD #(
	.DEBUG_CAPTURE(0),
	.DEBUG_DECODE(0)
) u_capture_and_decode(
    .clk         (clk),
    .ce          (ce & conf_ready & enable_morse), // Włączenie modułu jedynie, jeśli jesteśmy w trybie Morse'a i Konfiguracja jest wyznaczona
	 .aclr		  ((!enable_morse) || (!conf_ready)), // Jeśli nie, to resetowanie modułu
	 .dit_time    (dit_time),
	 .dah_time    (dah_time),
	 .word_time   (word_time),
	 .tol_time    (tol_time),
    .signal      (signal),
	 .capture_running (capture_running),
    .word        (decode_word),
    .word_ended  (decode_word_ended),
    .error       (decode_error)
);

// Multiplekser, wybierający co wyświetlić na wyświetlaczach 7-segmentowych - wartość opcji w MENU lub odczytane słowo z sygnałów Morse'a
wire [`UNIT_BCD_W*`CHAR_W-1 : 0] word_to_show = enable_morse ? decode_word : menu_word;

// Periodyczna zmiana sygnału do_blink, powodującego muiganie wybranych cyfr na wyświetlaczach w trybie MENU
wire blink_ceo;
PRESCALER #(.MAX(`BLINK_FREQ)) blink_prescaler(
    .clk(clk),
    .ce(ce),
    .ceo(blink_ceo)
);
reg do_blink = 0;
always @(posedge clk) begin
	if(ce && blink_ceo)
		do_blink <= !do_blink & (~enable_morse);
end

// Zamiana kodów znaków wyświetlanego słowa na sygnały do wyświetlaczów 7-segmentowych, z uwzględnieniem migania
CHAR2SEG u_seg0 (blinking[0] & do_blink, word_to_show >> (0 * `CHAR_W), HEX0);
CHAR2SEG u_seg1 (blinking[1] & do_blink, word_to_show >> (1 * `CHAR_W), HEX1);
CHAR2SEG u_seg2 (blinking[2] & do_blink, word_to_show >> (2 * `CHAR_W), HEX2);
CHAR2SEG u_seg3 (blinking[3] & do_blink, word_to_show >> (3 * `CHAR_W), HEX3);
CHAR2SEG u_seg4 (blinking[4] & do_blink, word_to_show >> (4 * `CHAR_W), HEX4);
CHAR2SEG u_seg5 (blinking[5] & do_blink, word_to_show >> (5 * `CHAR_W), HEX5);

// Przypisanie sygnałów do LED'ów sygnalizujących
assign LED_Error 		= decode_error;
assign LED_WordEnded = decode_word_ended;
assign LED_Running   = capture_running;
assign LED_Morse		= enable_morse;
assign LED_Ready		= conf_ready;
assign LED_Signal		= signal;

endmodule