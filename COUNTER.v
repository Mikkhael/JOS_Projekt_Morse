module COUNTER
#(
    parameter W   = 4
)
(
    input clk,
    input sclr,
    input ce,

    output reg [W-1 : 0] cnt = 0
);

always @(posedge clk) begin
    if(ce) begin
        if(sclr) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1'd1;
        end
    end
end
endmodule