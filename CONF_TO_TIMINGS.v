`include "defines.vh"

module CONF_TO_TIMINGS
(
    clk,
    ce,
    update,

	dit_units,
	dah_units,
	word_units,
	tol_units,
	pulses_per_unit,

	dit_time,
	dah_time,
	word_time,
	tol_time,

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

wire [4 : 0] bcds_ready;

BCD_TO_BIN bcd0 (.clk(clk), .ce(ce), .start(update), .in(dit_units),       .out(dit_units_bin),       .ready(bcds_ready[0]));
BCD_TO_BIN bcd1 (.clk(clk), .ce(ce), .start(update), .in(dah_units),       .out(dah_units_bin),       .ready(bcds_ready[1]));
BCD_TO_BIN bcd2 (.clk(clk), .ce(ce), .start(update), .in(word_units),      .out(word_units_bin),      .ready(bcds_ready[2]));
BCD_TO_BIN bcd3 (.clk(clk), .ce(ce), .start(update), .in(tol_units),       .out(tol_units_bin),       .ready(bcds_ready[3]));
BCD_TO_BIN bcd4 (.clk(clk), .ce(ce), .start(update), .in(pulses_per_unit), .out(pulses_per_unit_bin), .ready(bcds_ready[4]));


assign dit_time  = dit_units_bin  * pulses_per_unit_bin;
assign dah_time  = dah_units_bin  * pulses_per_unit_bin;
assign word_time = word_units_bin * pulses_per_unit_bin;
assign tol_time  = tol_units_bin  * pulses_per_unit_bin;

assign ready = (&bcds_ready) && (!update);

endmodule


module BCD_TO_BIN
#(
    parameter DIGITS = `UNIT_BCD_W,
    parameter OUT_W  = `PULSE_CNT_HALF_W
)(
    clk,
    ce,
    start,

    in,
    out,
    ready

);

input clk;
input ce;
input start;

input wire [DIGITS*4-1 : 0] in;
output reg [OUT_W-1    : 0] out = 0;
output wire ready;

reg [DIGITS*4-1 : 0] in_buffer = 0;
reg [2:0] ops_left = 0;
assign ready = (ops_left == 0) && !start;

always @(posedge clk) begin
    if(ce) begin
        if(start) begin
            out <= 0;
            in_buffer <= in;
            ops_left <= DIGITS;
        end else if(ops_left != 0) begin
            out <= (out << 3) + (out << 1) + in_buffer[DIGITS*4-1 : DIGITS*4-4];
            in_buffer <= in_buffer << 4;
            ops_left <= ops_left - 1'd1;
        end
    end
end

endmodule