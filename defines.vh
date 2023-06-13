`ifndef DEFS
`define DEFS

`define MANUAL_DEBUG

`define UNIT_BCD_W       6
`define PULSE_CNT_W      40
`define PULSE_CNT_HALF_W 20

`define MAX_MORSE_LEN    5
`define MORSE_LEN_W      3
`define CHAR_W           7
`define MAX_CHARS        6

`define DISPLAY_MODE_W   2
`define DISPLAY_MENU     2'd0
`define DISPLAY_CONF     2'd1
`define DISPLAY_MORSE    2'd2


`define CHAR_CODE__   `CHAR_W'd31

`define CHAR_CODE_0   `CHAR_W'd0
`define CHAR_CODE_1   `CHAR_W'd1
`define CHAR_CODE_2   `CHAR_W'd2
`define CHAR_CODE_3   `CHAR_W'd3
`define CHAR_CODE_4   `CHAR_W'd4
`define CHAR_CODE_5   `CHAR_W'd5
`define CHAR_CODE_6   `CHAR_W'd6
`define CHAR_CODE_7   `CHAR_W'd7
`define CHAR_CODE_8   `CHAR_W'd8
`define CHAR_CODE_9   `CHAR_W'd9
`define CHAR_CODE_A   `CHAR_W'd10
`define CHAR_CODE_B   `CHAR_W'd11
`define CHAR_CODE_C   `CHAR_W'd12
`define CHAR_CODE_D   `CHAR_W'd13
`define CHAR_CODE_E   `CHAR_W'd14
`define CHAR_CODE_F   `CHAR_W'd15

`define CHAR_CODE_G   `CHAR_W'd16
`define CHAR_CODE_H   `CHAR_W'd17
`define CHAR_CODE_I   `CHAR_W'd18
`define CHAR_CODE_J   `CHAR_W'd19
`define CHAR_CODE_K   `CHAR_W'd20
`define CHAR_CODE_L   `CHAR_W'd21
`define CHAR_CODE_M   `CHAR_W'd22
`define CHAR_CODE_N   `CHAR_W'd23
`define CHAR_CODE_O   `CHAR_W'd24
`define CHAR_CODE_P   `CHAR_W'd25
`define CHAR_CODE_Q   `CHAR_W'd26
`define CHAR_CODE_R   `CHAR_W'd27
`define CHAR_CODE_S   `CHAR_W'd28
`define CHAR_CODE_T   `CHAR_W'd29
`define CHAR_CODE_U   `CHAR_W'd30
`define CHAR_CODE_V   `CHAR_W'd31
`define CHAR_CODE_W   `CHAR_W'd32
`define CHAR_CODE_X   `CHAR_W'd33
`define CHAR_CODE_Y   `CHAR_W'd34
`define CHAR_CODE_Z   `CHAR_W'd35

`define MENU_INDEX_W     2
`define MENU_INDEX_MAX   2

`define MENU_NAME_DIT    {`CHAR_CODE__, `CHAR_CODE__, `CHAR_CODE__, `CHAR_CODE_D, `CHAR_CODE_I, `CHAR_CODE_T}
`define MENU_NAME_DAH    {`CHAR_CODE__, `CHAR_CODE__, `CHAR_CODE__, `CHAR_CODE_D, `CHAR_CODE_A, `CHAR_CODE_H}
`define MENU_NAME_START  {`CHAR_CODE__, `CHAR_CODE_S, `CHAR_CODE_T, `CHAR_CODE_A, `CHAR_CODE_R, `CHAR_CODE_T}


`define CHAR_ASCI_ARRAY  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

`define CHAR_MORSE_A   ".-"
`define CHAR_MORSE_B   "-..."
`define CHAR_MORSE_C   "-.-."
`define CHAR_MORSE_D   "-.."
`define CHAR_MORSE_E   "."
`define CHAR_MORSE_F   "..-."




`endif