`include "timescale.v"

`define TB_TOP tb_video
module `TB_TOP;

reg fpga_rst;
initial
begin
    fpga_rst = 1'b1;
    #10 fpga_rst = 1'b0;
end

//
//  CLOCK GENERATION
//

reg     ref_clk;
initial
begin
  ref_clk = 1'b0;
end

  // VIDEO CLOCK - 40MHz
always
  #12.5 ref_clk = ~ref_clk;

// inputs

// outputs
wire        strobe;
wire [9:0]  x;
wire [9:0]  y;
wire        hblank;
wire        vblank;
wire [9:0]  red;
wire [9:0]  green;
wire [9:0]  blue;
wire        hsync;
wire        vsync;

wire [12:0] tilemap_a;
wire [7:0]  tilemap_d;
wire [12:0] tile_a;
wire [7:0]  tile_d;
wire [9:0]  attr_a;

wire [12:0] tilemap_a2;
wire [7:0]  tilemap_d2;
wire [12:0] tile_a2;
wire [7:0]  tile_d2;
wire [9:0]  attr_a2;

reg					vid_outsel;
wire [9:0]	vid_r;
wire [9:0]	vid_g;
wire [9:0]	vid_b;
wire [9:0]	pac_r;
wire [9:0]	pac_g;
wire [9:0]	pac_b;
wire [9:0]	trs_r;
wire [9:0]	trs_g;
wire [9:0]	trs_b;

// Main simulation loop

assign vid_r = vid_outsel ? pac_r : trs_r;
assign vid_g = vid_outsel ? pac_g : trs_g;
assign vid_b = vid_outsel ? pac_b : trs_b;

initial
begin
  // initialise simulation environment

  // wait for reset to go away
  @(negedge fpga_rst);

  // wait a bit
  repeat (4) @(posedge ref_clk);

	vid_outsel = 0;
  @(posedge vblank);
  @(posedge vblank);

	vid_outsel = 1;
  @(posedge vblank);
  @(posedge vblank);

  $stop;

end

//
// Video Controller module
//
VGAController VGAController_1
(
    .clk          (ref_clk),
    .reset        (fpga_rst),

    .strobe     	(strobe),
		.pixel_x			(x),
		.pixel_y			(y),
    .hblank     	(hblank),
    .vblank     	(vblank),

		.r_i			    (vid_r),
		.g_i				  (vid_g),
		.b_i					(vid_b),

    .red        	(red),
    .green      	(green),
    .blue       	(blue),
    .hsync      	(hsync),
    .vsync      	(vsync)
);

mapCtl_1 mapCtl_pacman
(
    .clk          (ref_clk),
		.clk_ena			(strobe),
    .reset        (fpga_rst),

		// video control signals		
    .hblank       (hblank),
    .vblank       (vblank),
    .pix_x        (x),
    .pix_y        (y),

    // tilemap interface
    .tilemap_d    (tilemap_d),
    .tilemap_a    (tilemap_a),
    .tile_d       (tile_d),
    .tile_a       (tile_a),
    .attr_d       (16'b0000000000000000),
    .attr_a       (attr_a),

		// RGB output (10-bits each)
		.rgb.r				(pac_r),
		.rgb.g				(pac_g),
		.rgb.b				(pac_b)
);

mapCtl_3 mapCtl_trs80
(
    .clk          (ref_clk),
		.clk_ena			(strobe),
    .reset        (fpga_rst),

		// video control signals		
    .hblank       (hblank),
    .vblank       (vblank),
    .pix_x        (x),
    .pix_y        (y),

    // tilemap interface
    .tilemap_d    (tilemap_d2),
    .tilemap_a    (tilemap_a2),
    .tile_d       (tile_d2),
    .tile_a       (tile_a2),
    .attr_d       (16'b0000000000000000),
    //.attr_a       (attr_a)

		// RGB output (10-bits each)
		.r						(trs_r),
		.g						(trs_g),
		.b						(trs_b)
);

dummy_mem tilemap_mem_1
(
  .clk            (ref_clk),
  .addr           (tilemap_a),
  .data           (tilemap_d)
);

dummy_mem tile_mem_1
(
  .clk            (ref_clk),
  .addr           (tile_a),
  .data           (tile_d)
);

dummy_mem tilemap_mem_2
(
  .clk            (ref_clk),
  .addr           (tilemap_a2),
  .data           (tilemap_d2)
);

dummy_mem tile_mem_2
(
  .clk            (ref_clk),
  .addr           (tile_a2),
  .data           (tile_d2)
);

endmodule

module dummy_mem (clk, addr, data);
  input         clk;
  input [12:0]  addr;
  output [7:0]  data;

  reg [7:0]     data;

  always @(posedge clk)
    #10 data <= addr[7:0];

endmodule


