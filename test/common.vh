

task WAIT(input integer rep, output reg clk);
    integer i = 0;
    for(i = 0; i < rep; i = i + 1 ) begin
        clk = 1'd1; #10;
        clk = 1'd0; #10;
    end
endtask