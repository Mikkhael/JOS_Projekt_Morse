`include "defines.vh"

module MORSE_CAPTURE_CHAR(
    clk,
    ce,

	dit_units,
	dah_units,
	pause_units,
	char_units,
	word_units,
	tol_units,

    signal,
    clr,

    len,
    dits_dahs,
    error,

    char_end,
    word_end,

    units_cnt

);

input wire clk;
input wire ce;

input wire [`UNIT_BCD_W*4-1 : 0] dit_units;
input wire [`UNIT_BCD_W*4-1 : 0] dah_units;
input wire [`UNIT_BCD_W*4-1 : 0] pause_units;
input wire [`UNIT_BCD_W*4-1 : 0] char_units;
input wire [`UNIT_BCD_W*4-1 : 0] word_units;
input wire [`UNIT_BCD_W*4-1 : 0] tol_units;

input wire signal;
input wire clr;

output reg [`MORSE_LEN_W-1   : 0] len = 0;
output reg [`MAX_MORSE_LEN-1 : 0] dits_dahs = 0;
output reg error = 0;
output reg char_end = 0;
output reg word_end = 0;



output wire [`UNIT_BCD_W*4-1 : 0] units_cnt;

reg enable_counter = 0;
reg clear_counter  = 0;


BCD_COUNTER #(
    .DIGITS( `UNIT_BCD_W )
) units_counter (
    .clk(clk),
    .ce(ce & enable_counter),
    .clr(clear_counter),
    .cnt(units_cnt)
);

reg last_signal = 0;

always @(posedge clk) begin
    
    if(clr) begin
        dits_dahs <= 0;
        len <= 0;
        char_end <= 0;
        word_end <= 0;
        error <= 0;
    end else if(ce) begin
        if(last_signal == 1'd1) begin
            if(signal == 1'd0) begin
                len <= len + 1'd1;
                clear_counter <= 1;
                last_signal <= 0;
                if(units_cnt <= dit_units) begin
                    dits_dahs <= (dits_dahs << 1'd1) + 1'd1;
                end else if(units_cnt <= dah_units) begin
                    dits_dahs <= (dits_dahs << 1'd1);
                end else begin
                    dits_dahs <= (dits_dahs << 1'd1);
                    error <= 1;
                end
            end else begin
                clear_counter <= 0; 
            end
        end else begin
            if(signal == 1'd1) begin
                last_signal <= 1;
                clear_counter <= 1;
                if(units_cnt <= pause_units) begin
                    error <= 1;
                end
            end else begin
                clear_counter <= 0;
                if(units_cnt >= char_units) begin
                    char_end <= 1;
                end
                if(units_cnt >= word_units) begin
                    word_end <= 1;
                end
            end                                         
        end
    end

end



endmodule