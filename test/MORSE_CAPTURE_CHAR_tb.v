`timescale 1ps/1ps

`include "../defines.vh"

module MORSE_CAPTURE_CHAR_tb();

reg clk = 0;
reg ce = 1;
reg start = 0;
reg signal = 0;

reg  [`PULSE_CNT_W-1 : 0] DIT  = 10;
reg  [`PULSE_CNT_W-1 : 0] DAH  = 30;
reg  [`PULSE_CNT_W-1 : 0] WORD = 70;
reg  [`PULSE_CNT_W-1 : 0] TOL  = 5;
wire [`PULSE_CNT_W-1 : 0] CHAR_END  = DAH  + 1'd1;
wire [`PULSE_CNT_W-1 : 0] WORD_END  = WORD + 1'd1;
wire [`PULSE_CNT_W-1 : 0] SIM_TOL = TOL;

wire  [`MORSE_LEN_W-1   : 0] len;
wire  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
wire error;
wire word_end;
wire capture_ceo;

MORSE_CAPTURE_CHAR u_capture(
    .clk(clk),
    .ce(ce),
	.start(start),
	.dit_time(DIT),
	.dah_time(DAH),
	.word_time(WORD),
	.tol_time(TOL),
    .signal(signal),
    .len(len),
    .dits_dahs(dits_dahs),
    .error(error),
    .word_end(word_end),
	.ceo(capture_ceo)
);

reg  expected_word_end = 0;
reg  [`MORSE_LEN_W-1   : 0] expected_len = 0;
reg  [`MAX_MORSE_LEN-1 : 0] expected_dits_dahs = 0;
reg is_good = 1;

always @(posedge clk) begin
    
    if(word_end & capture_ceo) begin
        $write("WORD END ");
        if(expected_word_end)  begin
            $display("[OK]");
        end else begin
            $display("[ INVALID !!! ]");
            is_good = 0;
        end
        expected_word_end = 0;
    end
    else if(capture_ceo) begin
        $write("CHAR END: %b (len: %2d) (error: %1b) ", dits_dahs, len, error);
        if(
            !error && 
            expected_len == len &&
            expected_dits_dahs == ( dits_dahs & ((1 << len) - 1'd1) )
        ) begin
            $display("[OK]");
        end else begin
            $display("[ INVALID !!! ] - EXPECTED: %b (len: %2d)", expected_dits_dahs, expected_len);
            is_good = 0;
        end
        expected_len = 0;
        expected_dits_dahs = 0;
    end

end

initial begin
    ce = 0;
    WAIT(10);
    ce = 1;

    START();
    TEST_STR_CHAR("--.-.", 0);
    TEST_STR_CHAR("...",   0);
    TEST_STR_CHAR("---",   1);

    START();
    TEST_STR_CHAR("---.",  0);
    TEST_STR_CHAR("...-",  1);

    START();
    TEST_STR_CHAR(".-.-.", 1);

    START();
    TEST_STR_CHAR("-.-.-", 0);
    TEST_STR_CHAR(".",     0);
    TEST_STR_CHAR("-",     1);

    $display("==========================");
    $display("== TESTS SUCCESSFUL: %b ==", is_good);
    $display("==========================");
    $stop;
end

task automatic WAIT(input integer rep);
    integer i = 0;
begin
    for(i = 0; i < rep; i = i + 1 ) begin
        clk = 1'd1; #10;
        clk = 1'd0; #10;
    end
end
endtask

task automatic WAIT_TOL(input integer rep);
begin
    WAIT(rep + ({$random} % (2*SIM_TOL + 1)) - SIM_TOL);
end
endtask

task automatic START();
begin
    #10;
    start = 1;
    WAIT(1);
    start = 0;
end
endtask

task automatic SEND_SIGNAL(input state, input [`PULSE_CNT_W-1 : 0] pulses);
begin
    signal = state;
    WAIT_TOL(pulses);
end
endtask

task automatic SEND_ON_OFF(input [`PULSE_CNT_W-1 : 0] on, input [`PULSE_CNT_W-1 : 0] off);
begin
    SEND_SIGNAL(1, on);
    SEND_SIGNAL(0, off);
end
endtask

function automatic reg [7:0] get_char_at(input [10*8-1:0] str, input integer i);
begin
    get_char_at = str >> (i*8);
end
endfunction

function automatic integer get_length(input [10*8-1:0] str);
    integer i;
begin
    get_length = 0;
    for(i=0; i<10; i = i+1) begin
        if(get_char_at(str, i) != 0) begin
            get_length = get_length + 1;
        end
    end
end
endfunction

function automatic [`MORSE_LEN_W+`MAX_MORSE_LEN-1 : 0] str_to_dits_dahs_len(input [10*8-1 : 0] str);
    integer i;
    reg [`MORSE_LEN_W-1   : 0] len;
    reg [`MAX_MORSE_LEN-1 : 0] dds;
begin
    len = get_length(str);
    dds = 0;
    for(i = 0; i < len; i = i + 1) begin
        if(get_char_at(str, i) == "-") begin
            dds = dds | (1 << i);
        end
    end
    str_to_dits_dahs_len = {dds, len};
end
endfunction

task automatic SEND_STR_CHAR_PART(input [7:0] ch, input end_char, input end_word);
begin
    if(ch == "." || ch == "-") begin
        SEND_SIGNAL(1, ch == "." ? DIT : DAH);
        if(end_word) begin
            SEND_SIGNAL(0, WORD_END);
        end else if(end_char) begin
            SEND_SIGNAL(0, CHAR_END);
        end else begin
            SEND_SIGNAL(0, DIT);
        end
    end
end
endtask

task automatic TEST_STR_CHAR(input [10*8-1:0] str, input end_word);
    integer i;
begin
    {expected_dits_dahs, expected_len} = str_to_dits_dahs_len(str);
    expected_word_end = end_word;
    $display("EXPECT    %b (len: %2d) (word_end: %b)", expected_dits_dahs, expected_len, expected_word_end);
    for(i = expected_len-1; i >= 0; i = i - 1) begin
        SEND_SIGNAL(1, ( expected_dits_dahs & (1 << i) ) ? DAH : DIT );
        if(i == 0) begin
            SEND_SIGNAL(0, end_word ? WORD_END : CHAR_END);
        end else begin
            SEND_SIGNAL(0, DIT);
        end
    end
    WAIT(1);
end
endtask



endmodule