`include "defines.vh"

module PULSES_TO_UNITS(
    clk,
    ce,
    clr,

    pulses_per_unit,
    max_units,

    signal

    units_cnt
);

input wire clk;
input wire ce;
input wire clr;

input wire [`UNIT_BCD_W*4-1 : 0] pulses_per_unit;
input wire [`UNIT_BCD_W*4-1 : 0] max_units;

input wire signal;

output reg [`UNIT_BCD_W*4-1 : 0] units_cnt = 0;

reg clear_counter  = 0;
reg enable_counter = 0;

BCD6_COUNTER units_counter(
    .clk(clk),
    .clr(clear_counter),
    .ce (ce & enable_counter),
    .cnt(units_cnt)
);


localparam STATE_WAIT  = 2'd0;
localparam STATE_START = 2'd1;
localparam STATE_ON    = 2'd2;
localparam STATE_OFF   = 2'd3;
reg [1:0] state = STATE_WAIT;
reg last_signal = 0;

always @(posedge clk) begin
    
    if(ce) begin

        case(state)
        STATE_WAIT: begin
            if(signal == 1'd1) begin
                enable_counter <= 1;
                clear_counter  <= 0;
                state <= STATE_START;
            end else begin
                enable_counter <= 0;
                clear_counter  <= 1;
            end
        end
        STATE_START: begin
            if(signal == )
        end
        STATE_ON: begin

        end
        STATE_OFF: begin

        end


        endcase

        last_signal = signal;
    end
    

end



endmodule