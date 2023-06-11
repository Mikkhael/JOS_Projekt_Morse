module BCD_PART_COUNTER
#(
    parameter W   = 4,
    parameter MAX = 9
)
(
    input clk,
    input sclr,
    input ce,
    input set_one,

    output reg [W-1 : 0] cnt = 0,
    output wire ceo
);

assign ceo = ce && ( cnt == MAX );

always @(posedge clk) begin
    if(ce) begin
        if (set_one) begin
            cnt <= {{(W-1){1'd0}}, 1'd1};
        end else if(cnt == MAX || sclr) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1'd1;
        end
    end
end
endmodule


module BCD6_COUNTER
(
    input wire clk,
    input wire ce,
    input wire sclr,
    input wire set_one,

    output reg [6*4-1 : 0] cnt = 0
);

    wire [4:0] cnt_ce;

    BCD_PART_COUNTER cnt0( .clk(clk), .sclr(sclr),           .set_one(set_one), .ce(ce),        .cnt(cnt[ 3: 0]), .ceo(cnt_ce[0]));
    BCD_PART_COUNTER cnt1( .clk(clk), .sclr(sclr | set_one), .set_one(1'd0),    .ce(cnt_ce[0]), .cnt(cnt[ 7: 4]), .ceo(cnt_ce[1]));
    BCD_PART_COUNTER cnt2( .clk(clk), .sclr(sclr | set_one), .set_one(1'd0),    .ce(cnt_ce[1]), .cnt(cnt[11: 8]), .ceo(cnt_ce[2]));
    BCD_PART_COUNTER cnt3( .clk(clk), .sclr(sclr | set_one), .set_one(1'd0),    .ce(cnt_ce[2]), .cnt(cnt[15:12]), .ceo(cnt_ce[3]));
    BCD_PART_COUNTER cnt4( .clk(clk), .sclr(sclr | set_one), .set_one(1'd0),    .ce(cnt_ce[3]), .cnt(cnt[19:16]), .ceo(cnt_ce[4]));
    BCD_PART_COUNTER cnt5( .clk(clk), .sclr(sclr | set_one), .set_one(1'd0),    .ce(cnt_ce[4]), .cnt(cnt[23:20])                 );


endmodule