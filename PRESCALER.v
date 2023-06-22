// Preskaler, licznik zliczający w dół z wyjściem Clock Enable Output
module PRESCALER
#(
    parameter MAX = 9, // Wartość, od której zaczyna liczyć
    parameter W   = $clog2(MAX + 1) // Szerokość bitowa prescalera
)
(
    input clk,
    input ce,

    output reg ceo = 0
);


reg [W-1 : 0] cnt = MAX;

always @(posedge clk) begin
    if(ce) begin
        if(cnt == 0) begin
            cnt <= MAX;
            ceo <= 1;
        end else begin
            cnt <= cnt - 1'd1;
            ceo <= 0;
        end
    end
end

endmodule