

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


task automatic SEND_STR_CHAR(input [10*8-1:0] str, input end_word);
    integer i;
    reg  [`MORSE_LEN_W-1   : 0] len;
    reg  [`MAX_MORSE_LEN-1 : 0] dits_dahs;
begin
    {dits_dahs, len} = str_to_dits_dahs_len(str);
    for(i = len-1; i >= 0; i = i - 1) begin
        SEND_SIGNAL(1, ( dits_dahs & (1 << i) ) ? DAH : DIT );
        if(i == 0) begin
            SEND_SIGNAL(0, end_word ? WORD_END : CHAR_END);
        end else begin
            SEND_SIGNAL(0, DIT);
        end
    end
end
endtask

function [9*`MAX_CHARS-1 : 0] word_to_ascii(input [`CHAR_W*`MAX_CHARS-1 : 0] word);
    integer i;
begin
    for(i=0; i<`MAX_CHARS; i = i + 1) begin
        word_to_ascii = word_to_ascii >> 8;
        word_to_ascii[8*`MAX_CHARS-1 : 8*(`MAX_CHARS-1)] = `CHAR_ASCI_ARRAY >> (8*(31 - word[`CHAR_W-1 : 0]));
        word = word >> `CHAR_W;
    end
end
endfunction


