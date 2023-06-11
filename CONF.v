`include "defines.vh"

module CONF(
	
	dit_units,
	dah_units,
	pause_units,
	char_units,
	word_units,
	tol_units,

	pulses_per_unit
	
	
);

`ifdef MANUAL_DEBUG

	output reg [`UNIT_BCD_W*4-1 : 0] dit_units    = 24'd2;
	output reg [`UNIT_BCD_W*4-1 : 0] dah_units    = 24'd6;
	output reg [`UNIT_BCD_W*4-1 : 0] pause_units  = 24'd2;
	output reg [`UNIT_BCD_W*4-1 : 0] char_units   = 24'd6;
	output reg [`UNIT_BCD_W*4-1 : 0] word_units   = 24'd14;
	output reg [`UNIT_BCD_W*4-1 : 0] tol_units    = 24'd1;

	output reg [`UNIT_BCD_W*4-1 : 0] pulses_per_unit = 24'd1;

`else
	output reg [`UNIT_BCD_W*4-1 : 0] dit_units    = 24'd1000;
	output reg [`UNIT_BCD_W*4-1 : 0] dah_units    = 24'd3000;
	output reg [`UNIT_BCD_W*4-1 : 0] pause_units  = 24'd1000;
	output reg [`UNIT_BCD_W*4-1 : 0] char_units   = 24'd3000;
	output reg [`UNIT_BCD_W*4-1 : 0] word_units   = 24'd7000;
	output reg [`UNIT_BCD_W*4-1 : 0] tol_units    = 24'd0500;

	output reg [`UNIT_BCD_W*4-1 : 0] pulses_per_unit = 24'd50000;
`endif

endmodule