`include "defines.vh"

module UNITS_COUNTER
(
    input clk,
    input ce,
    input start,

    input  [6*4-1 : 0] subpulses_count,

    output [6*4-1 : 0] pulse_cnt,
    output [6*4-1 : 0] units_cnt
);

wire pulses_ceo;
assign pulse_ceo = subpulses_count == pulse_cnt;

BCD6_COUNTER pulse_counter(
    .clk     (clk),
    .en      (ce),
    .sclr    (pulses_ceo),
    .set_one (start),
    .cnt     (pulse_cnt)
);

BCD6_COUNTER units_counter(
    .clk     (clk),
    .ce      (ce && pulses_ceo),
    .sclr    (start),
    .set_one (1'd0),
    .cnt     (units_cnt)
);


endmodule