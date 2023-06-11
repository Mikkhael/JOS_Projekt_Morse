module BCD_COUNTER
#(
    parameter DIGITS = 6,
    parameter W      = 4,
    parameter MAX    = 9
)
(
    input wire clk,
    input wire ce,
    input wire clr,

    output reg [DIGITS*W-1 : 0] cnt = 0
);

reg [DIGITS : 1] carry = 0;

reg [3:0] i;
always @(posedge clk) begin
    if(clr) begin
        cnt <= 0;
        carry <= 0;
    end else if(ce) begin
//        for(i=0; i<DIGITS; i=i+1) begin
//            if(i == 0 ? 1'd1 : carry[i]) begin
//                if( cnt[(i+1)*W-1 : i*W] == MAX ) begin
//                    cnt[(i+1)*W-1 : i*W] <= 0;
//                end else begin
//                    cnt[(i+1)*W-1 : i*W] <= cnt[(i+1)*W-1 : i*W] + 1'd1;
//                end
//                carry[i+1] <= (cnt[(i+1)*W-1 : i*W] == MAX - 1'd1);
//            end
//        end
			cnt <= cnt + 1'd1;
    end
end

endmodule