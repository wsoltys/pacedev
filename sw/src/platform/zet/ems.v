module ems #(
	parameter ems_version = 32
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
	$display("ems_version\t\t\t%d", ems_version);
	$display("ems_enabled\t\t\t%s", (ems_enabled ? "yes" : "no");
	// synthesis translate_on
end

  //
  // register interface
  //
  
  // supports 8-bit I/O only atm...
  wire [8:0] dat_i = (wb_sel_i[0] == 1 ? wb_dat_i[7:0] : wb_dat_i[15:8]);

  // dummy output for testing in QBASIC
  assign wb_dat_o = 16'h4242;
  
  always @(posedge wb_clk)
    wb_ack_o = wb_rst ? 1'b0 : (wb_cyc_i && wb_stb_i);

  // used to enable/disable EMS support
  reg ems_enabled;
  always @(posedge wb_clk)
    ems_enabled <= wb_rst ? 1'b0 : 1'b0;
    
  //
  // sdram interface
  //

  // base address of 64KB block in UMB [19:16]
  reg [19:16] umb_base_adr;
  // x4 page address registers for 16KB memory blocks [31:14]
  // - assume 8MB is the largest we can address
  reg [22:14] page_adr [3:0];

  always @(posedge wb_clk)
  begin
    // default address to segment $B000
    umb_base_adr <= wb_rst ? 4'hB : 4'hB;
    // 
    page_adr[0] <= wb_rst ? 8'h00 : 8'h00;
    page_adr[1] <= wb_rst ? 8'h01 : 8'h01;
    page_adr[2] <= wb_rst ? 8'h02 : 8'h02;
    page_adr[3] <= wb_rst ? 8'h03 : 8'h03;
  end

  wire page_frame_arena = (sdram_adr_i[19:16] == umb_base_adr);
  wire [1:0] page = sdram_adr_i[15:14];
  
  assign sdram_adr_o = ems_enabled && page_frame_arena
                        ? { 8'b0, page_adr[page], sdram_adr_i[13:1], 2'b00 }
                        : { 11'b0, sdram_adr_i, 2'b00 };

endmodule
