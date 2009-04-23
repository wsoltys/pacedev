module ems #(
	parameter ems_enabled = 1
) (
	/* WISHBONE interface */
	input wb_clk,
	input wb_rst,
	
	input [2:1] wb_adr_i,
	input [15:0] wb_dat_i,
	output [15:0] wb_dat_o,
	input [1:0] wb_sel_i,
	input wb_cyc_i,
	input wb_stb_i,
	input wb_we_i,
	output reg wb_ack_o,

	/* address interface */
	input [19:1] sdram_adr_i,
	output [31:0] sdram_adr_o
);

initial begin
	// synthesis translate_off
	$display("=== EMS parameters ===");
	
	$display("ems_enabled\t\t\t%d", ems_enabled);
	// synthesis translate_on
end

  // supports 8-bit I/O only atm...
  wire [8:0] dat_i = (wb_sel_i[0] == 1 ? wb_dat_i[7:0] : wb_dat_i[15:8]);

  assign sdram_adr_o = { 11'b0, sdram_adr_i, 2'b00 };

  // dummy output for testing in QBASIC
  assign wb_dat_o = 16'h4242;
  
  always @(posedge wb_clk)
    wb_ack_o = wb_rst ? 1'b0 : (wb_cyc_i && wb_stb_i);
  
endmodule

