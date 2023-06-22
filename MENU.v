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

    menu_word,
    blinking
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

output reg [`UNIT_BCD_W*`CHAR_W-1:0] menu_word;
output wire [`UNIT_BCD_W-1:0] blinking;


wire btn_up_edge;
wire btn_dn_edge;
wire btn_lf_edge;
wire btn_rt_edge;

NEGEDGE_DETECT ned_up (clk, ce, btn_up, btn_up_edge);
NEGEDGE_DETECT ned_dn (clk, ce, btn_dn, btn_dn_edge);
NEGEDGE_DETECT ned_lf (clk, ce, btn_lf, btn_lf_edge);
NEGEDGE_DETECT ned_rt (clk, ce, btn_rt, btn_rt_edge);


parameter MODE_MENU  = 0;
parameter MODE_CONF  = 1;

reg [0:0] mode = MODE_MENU;
reg await = 0;

reg [`MENU_INDEX_W-1 : 0] menu_index = 0;
reg [`UNIT_BCD_W-1   : 0] menu_cell = 1;

assign blinking = (mode == MODE_CONF) ? menu_cell : 0;

`define change_cell_routine(off) begin \
    casex({conf_selected_new_value[off*4+3 : off*4] , btn_dn_edge}) \
        5'b00001: conf_selected_new_value[off*4+3 : off*4] <= 4'd9; \
        5'b10010: conf_selected_new_value[off*4+3 : off*4] <= 4'd0; \
        5'bxxxx1: conf_selected_new_value[off*4+3 : off*4] <= conf_selected_new_value[off*4+3 : off*4] - 1'd1; \
        5'bxxxx0: conf_selected_new_value[off*4+3 : off*4] <= conf_selected_new_value[off*4+3 : off*4] + 1'd1; \
    endcase \
end

always @(posedge clk) begin
    if(ce) begin
        case(mode)
        MODE_MENU: begin

            case(menu_index)
                `MENU_INDEX_W'd0: menu_word <= `MENU_WORD_DIT;
                `MENU_INDEX_W'd1: menu_word <= `MENU_WORD_DAH;
                `MENU_INDEX_W'd2: menu_word <= `MENU_WORD_WORD;
                `MENU_INDEX_W'd3: menu_word <= `MENU_WORD_TOL;
                `MENU_INDEX_W'd4: menu_word <= `MENU_WORD_PPU;
            endcase

                 if(btn_up_edge) menu_index <= (menu_index != 0)               ? menu_index - 1'd1 : menu_index;
            else if(btn_dn_edge) menu_index <= (menu_index != `MENU_INDEX_MAX) ? menu_index + 1'd1 : menu_index;
            else if(btn_rt_edge) begin
                mode <= MODE_CONF;
                conf_selected_index <= menu_index;
                await <= 1;
            end
        end


        MODE_CONF: begin
            if(await) begin
                await <= 0;
                conf_selected_new_value <= conf_selected_value;
                conf_selected_set <= 0;
            end else begin
                     if(btn_rt_edge) menu_cell <= {menu_cell[`UNIT_BCD_W-2 : 0], menu_cell[`UNIT_BCD_W-1]};
                else if(btn_lf_edge) begin
                    mode <= MODE_MENU;
                end
                else if(btn_dn_edge || btn_up_edge) begin
                    casex(menu_cell)
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
                menu_word[`CHAR_W-1+`CHAR_W*0 : `CHAR_W*0] <= {{(`CHAR_W-4){1'b0}}, conf_selected_new_value[4-1+4*0 : 4*0]};
                menu_word[`CHAR_W-1+`CHAR_W*1 : `CHAR_W*1] <= {{(`CHAR_W-4){1'b0}}, conf_selected_new_value[4-1+4*1 : 4*1]};
                menu_word[`CHAR_W-1+`CHAR_W*2 : `CHAR_W*2] <= {{(`CHAR_W-4){1'b0}}, conf_selected_new_value[4-1+4*2 : 4*2]};
                menu_word[`CHAR_W-1+`CHAR_W*3 : `CHAR_W*3] <= {{(`CHAR_W-4){1'b0}}, conf_selected_new_value[4-1+4*3 : 4*3]};
                menu_word[`CHAR_W-1+`CHAR_W*4 : `CHAR_W*4] <= {{(`CHAR_W-4){1'b0}}, conf_selected_new_value[4-1+4*4 : 4*4]};
                menu_word[`CHAR_W-1+`CHAR_W*5 : `CHAR_W*5] <= {{(`CHAR_W-4){1'b0}}, conf_selected_new_value[4-1+4*5 : 4*5]};
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

always @(posedge clk) begin
    if(ce) begin
        out  <= last && (!in);
        last <= in;
    end
end

endmodule