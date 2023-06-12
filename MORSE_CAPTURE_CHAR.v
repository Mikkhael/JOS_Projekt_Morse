`include "defines.vh"

module MORSE_CAPTURE_CHAR(
    clk,
    ce,
    start,

	dit_time,
	dah_time,
	word_time,
	tol_time,

    signal,

    len,
    dits_dahs,
    error,

    word_end,
    ceo

);

input wire clk;
input wire ce;
input wire start;

input wire [`PULSE_CNT_W-1 : 0] dit_time;
input wire [`PULSE_CNT_W-1 : 0] dah_time;
input wire [`PULSE_CNT_W-1 : 0] word_time;
input wire [`PULSE_CNT_W-1 : 0] tol_time;

input wire signal;

output reg [`MORSE_LEN_W-1   : 0] len = 0;
output reg [`MAX_MORSE_LEN-1 : 0] dits_dahs = 0;
output reg error = 0;

output reg word_end = 0;
output wire ceo;


wire [`PULSE_CNT_W-1 : 0] pulse_cnt;

reg char_end = 0;
reg last_char_end = 0;
reg last_word_end = 0;
assign ceo = ce & (
    char_end & (~last_char_end) |
    word_end & (~last_word_end)
);

reg run = 0;
reg last_signal = 0;

COUNTER #(.W(`PULSE_CNT_W), .SCLR_VAL(1'd1)) u_pulse_counter(
    .clk  (clk),
    .ce   (ce & (run | start)),
    .sclr (last_signal ^ signal),
    .cnt  (pulse_cnt)
);

task add_char(input new_dit_dah); 
begin
    // $display("ADDING DIT_DAH %b", new_dit_dah);
    if(len == `MAX_MORSE_LEN) begin
        error <= 1'd1;
        $display("ERROR - TO LONG");
    end
    len <= len + 1'd1;
    dits_dahs <= {dits_dahs[`MAX_MORSE_LEN-2:0], new_dit_dah};
end
endtask



wire [`PULSE_CNT_W-1 : 0] maximal_dit_time  = dit_time[`PULSE_CNT_W-1 : 1] + dah_time[`PULSE_CNT_W-1 : 1];
wire [`PULSE_CNT_W-1 : 0] maximal_dah_time  = dah_time  + tol_time;
wire [`PULSE_CNT_W-1 : 0] minimal_char_time = dah_time  - tol_time;
wire [`PULSE_CNT_W-1 : 0] minimal_word_time = word_time - tol_time;

always @(posedge clk) begin
    
    if(ce) begin
        if(start) begin
            // $display("CAPTURE STARTING");
            last_signal <= signal;
            run         <= 1'd1;
            char_end    <= 1'd0;
            word_end    <= 1'd0;
            len <= 0;
        end
        if(run) begin
            case({last_signal, signal})
            2'b00: begin
                if (pulse_cnt >= minimal_char_time) begin
                    char_end <= 1'd1;
                end
                if (pulse_cnt >= minimal_word_time) begin
                    // $display("CAPTURE 00 - %d (word_end)", pulse_cnt);
                    word_end <= 1'd1;
                    run <= 1'd0;
                end
            end
            2'b01: begin
                // $display("CAPTURE 01 - %d (word_end=%b, char_end=%b)", pulse_cnt, word_end, char_end);
                char_end <= 1'd0;
                word_end <= 1'd0;
                if(char_end || word_end) begin
                    len <= 0;
                end
            end
            2'b11: begin
                if( pulse_cnt > maximal_dah_time) begin
                    // $display("CAPTURE 11 - %d (abort)", pulse_cnt);
                    run <= 1'd0;
                    error <= 1'd1;
                    word_end <= 1'd1;
                end
            end
            2'b10: begin
                // $display("CAPTURE 10 - %d", pulse_cnt);
                if ( pulse_cnt > maximal_dit_time ) begin
                    add_char(1);
                end else begin
                    add_char(0);
                end
            end
            endcase
        end else begin
            error <= 1'd0;
            word_end <= 1'd0;
            char_end <= 1'd0;
        end
        last_signal <= signal;
        last_char_end <= char_end;
        last_word_end <= word_end;
    end
    

end



endmodule