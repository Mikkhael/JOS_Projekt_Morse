`timescale 1ps/1ps
`include "../defines.vh"

module MENU_tb();

reg clk    = 0;
reg ce     = 1;
reg update = 1;

MENU u_menu(
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


endmodule
