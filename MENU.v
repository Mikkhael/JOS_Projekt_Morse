`include "defines.vh"



module MENU(
    clk,
    ce,

    btn_up,
    btn_dn,
    btn_lf,
    btn_rt,

	conf_selected_index,
	conf_selected_value,
	conf_selected_new_value,
	conf_selected_set,

    enable_morse
);

input wire clk;
input wire ce;

input wire btn_up;
input wire btn_dn;
input wire btn_lf;
input wire btn_rt;

output reg [2:0] conf_selected_index = 0;
input wire [`UNIT_BCD_W*4-1 : 0] conf_selected_value;
output reg [`UNIT_BCD_W*4-1 : 0] conf_selected_new_value = 0;
output reg conf_selected_set = 0;

output reg [`DISPLAY_MODE_W-1:0] display_mode = `DISPLAY_MENU;
output reg enable_morse = 0;


wire btn_up_edge;
wire btn_dn_edge;
wire btn_lf_edge;
wire btn_rt_edge;

NEGEDGE_DETECT ned_up (clk, en, btn_dn, btn_up_edge);
NEGEDGE_DETECT ned_dn (clk, en, btn_dn, btn_dn_edge);
NEGEDGE_DETECT ned_lf (clk, en, btn_lf, btn_lf_edge);
NEGEDGE_DETECT ned_rt (clk, en, btn_rt, btn_rt_edge);


parameter MODE_MENU  = 0;
parameter MODE_CONF  = 1;
parameter MODE_MORSE = 2;

reg [1:0] mode = MODE_MENU;
reg await = 0;

reg [`MENU_INDEX_W-1 : 0] menu_index = 0;
reg [`UNIT_BCD_W-1   : 0] menu_cell = 1;

`define change_cell_routine(off) begin \
    case({conf_selected_new_value[off+3 : off] , btn_dn_edge} \
        {4'b00001}: conf_selected_new_value[off+3 : off] <= 4'd9; \
        {4'b10010}: conf_selected_new_value[off+3 : off] <= 4'd0; \
        {4'bxxxx1}: conf_selected_new_value[off+3 : off] <= conf_selected_new_value[off+3 : off] - 1'd1; \
        {4'bxxxx0}: conf_selected_new_value[off+3 : off] <= conf_selected_new_value[off+3 : off] + 1'd1; \
    endcase \
end

always @(posedge clk) begin
    if(ce) begin
        case(mode)
        MODE_MENU: begin
            display_mode <= `DISPLAY_MENU;
            enable_morse <= 0;
                 if(btn_up_edge) menu_index <= (menu_index != 0) ? menu_index - 1'd1 : `MENU_INDEX_MAX;
            else if(btn_dn_edge) menu_index <= (menu_index != `MENU_INDEX_MAX) ? menu_index + 1'd1 : 0;
            else if(btn_rt_edge) begin
                if(menu_index == 0) begin
                    mode <= MODE_MORSE;
                end else begin
                    mode <= MODE_CONF;
                    conf_selected_index <= menu_index - 1'd1;
                    await <= 1;
                end
            end
        end


        MODE_CONF: begin
            display_mode <= `DISPLAY_CONF;
            enable_morse <= 0;
            if(await) begin
                await <= 0;
                conf_selected_new_value <= conf_selected_value;
                conf_selected_set <= 0;
            end else begin
                     if(btn_rt_edge) menu_cell <= {menu_cell[0], menu_cell[`UNIT_BCD_W-1 : 1]};
                else if(btn_lf_edge) begin
                    mode <= MODE_MENU;
                end
                else if(btn_dn_edge || btn_up_edge) begin
                    case(menu_cell)
                        6'bxxxxx1 : `change_cell_routine(0)
                        6'bxxxx10 : `change_cell_routine(1)
                        6'bxxx100 : `change_cell_routine(2)
                        6'bxx1000 : `change_cell_routine(3)
                        6'bx10000 : `change_cell_routine(4)
                        default   : `change_cell_routine(5)
                    endcase
                    conf_selected_set <= 1;
                end else begin
                    conf_selected_set <= 0;
                end
            end            
        end


        MODE_MORSE: begin
            display_mode <= `DISPLAY_MORSE;
            enable_morse <= 1;
            if(`btn_lf_edge) begin
                mode <= MODE_MENU;
            end
        end
        endcase
    end
end


endmodule

module NEGEDGE_DETECT(
    input clk,
    input ce,
    input in,
    output reg out
);

reg last = 1;

always @(clk) begin
    if(ce) begin
        out  <= last && (!in);
        last <= in;
    end
end

endmodule