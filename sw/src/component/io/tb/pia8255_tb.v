// synopsys translate_off
`timescale 1 ps / 1 ps

module pia8255_tb;

// global simulation signals
reg         reset;
reg         clken;
reg  [1:0]  a;
reg  [7:0]  d_i;
wire [7:0]  d_o;
reg         cs;
reg         rd;
reg         wr;
reg  [7:0]  pa_i;
reg  [7:0]  pb_i;
reg  [7:0]  pc_i;
wire [7:0]  pa_o;
wire [7:0]  pb_o;
wire [7:0]  pc_o;

reg  [7:0]  tmpdata;

// clock generator
reg     clock_50;

always begin
  #10 clock_50 = ~clock_50;
end

pia8255 u0
(
    .clk     (clock_50),
    .clken   (clken),
  	.reset   (reset),
    .a       (a),
  	.d_i     (d_i),
  	.d_o     (d_o),
  	.cs      (cs),
    .rd      (rd),
    .wr      (wr),
    .pa_i    (pa_i),
    .pb_i    (pb_i),
    .pc_i    (pc_i),
    .pa_o    (pa_o),
    .pb_o    (pb_o),
    .pc_o    (pc_o)
);

// Read from 8255
task pia8255_rd;
  input  [1:0] Offset;
  output [7:0] Data;
begin
  a = Offset;
  rd = 1;
  @(posedge clock_50);
  Data = d_o;
  rd = 0;
end
endtask

// Write to 8255
task pia8255_wr;
  input  [1:0] Offset;
  input  [7:0] Data;
begin
  a = Offset;
	d_i = Data;
  wr = 1;
  @(posedge clock_50);
  wr = 0;
end
endtask

// Main test bench code
initial
begin
  clock_50 = 0;
  clken = 1;
  cs = 0;
  rd = 0;
  wr = 0;
  pa_i = 8'h55;
  pb_i = 8'hAA;
  pc_i = 8'hFF;

  reset = 1;
	repeat(10) @(posedge clock_50);
  reset = 0;

	// Mode 0 tests

	// Inputs

	cs = 1;

  pia8255_rd(0, tmpdata);
  if(tmpdata != 8'h55) begin
		$display("*** (%t) failed read port A", $time); #100 $stop;
  end

  pia8255_rd(1, tmpdata);
  if(tmpdata != 8'hAA) begin
		$display("*** (%t) failed read port B", $time); #100 $stop;
  end

  pia8255_rd(2, tmpdata);
  if(tmpdata != 8'hFF) begin
		$display("*** (%t) failed read port C", $time); #100 $stop;
  end

  pa_i = 8'h42;
  pb_i = 8'h69;
  pc_i = 8'hAB;

  pia8255_rd(0, tmpdata);
  if(tmpdata != 8'h42) begin
		$display("*** (%t) failed read port A", $time); #100 $stop;
  end

  pia8255_rd(1, tmpdata);
  if(tmpdata != 8'h69) begin
		$display("*** (%t) failed read port B", $time); #100 $stop;
  end

  pia8255_rd(2, tmpdata);
  if(tmpdata != 8'hAB) begin
		$display("*** (%t) failed read port C", $time); #100 $stop;
  end

	// Registers

  reset = 1;
	repeat(10) @(posedge clock_50);
  reset = 0;

  pia8255_rd(3, tmpdata);
  if(tmpdata != 8'h9B) begin
		$display("*** (%t) failed read ctrl", $time); #100 $stop;
  end

	pia8255_wr(3, 8'h80);

  pia8255_rd(3, tmpdata);
  if(tmpdata != 8'h80) begin
		$display("*** (%t) failed read ctrl", $time); #100 $stop;
  end

	// Outputs defaults FF for not driven

	reset = 1;
	cs = 0;
	#1;
	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

	reset = 0;
	@(posedge clock_50);
	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

	cs = 1;
	@(posedge clock_50);
	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(3, 8'h80);
    @(posedge clock_50);

    cs = 0;
    @(posedge clock_50);

	if(pa_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

	cs = 1;
	@(posedge clock_50);

	if(pa_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

	// Output registers

	pia8255_wr(0, 8'h53);

	if(pa_o != 8'h53) begin
		$display("*** (%t) failed output value wrong (%x != 0x53)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(1, 8'h76);

	if(pa_o != 8'h53) begin
		$display("*** (%t) failed output value wrong (%x != 0x53)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h76) begin
		$display("*** (%t) failed output value wrong (%x != 0x76)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(2, 8'h9A);

	if(pa_o != 8'h53) begin
		$display("*** (%t) failed output value wrong (%x != 0x53)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h76) begin
		$display("*** (%t) failed output value wrong (%x != 0x76)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h9A) begin
		$display("*** (%t) failed output value wrong (%x != 0x9A)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(1, 8'hAB);

	if(pa_o != 8'h53) begin
		$display("*** (%t) failed output value wrong (%x != 0x53)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hAB) begin
		$display("*** (%t) failed output value wrong (%x != 0xAB)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h9A) begin
		$display("*** (%t) failed output value wrong (%x != 0x9A)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(0, 8'h01);

	if(pa_o != 8'h01) begin
		$display("*** (%t) failed output value wrong (%x != 0x01)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hAB) begin
		$display("*** (%t) failed output value wrong (%x != 0xAB)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h9A) begin
		$display("*** (%t) failed output value wrong (%x != 0x9A)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(2, 8'h45);

	if(pa_o != 8'h01) begin
		$display("*** (%t) failed output value wrong (%x != 0x01)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hAB) begin
		$display("*** (%t) failed output value wrong (%x != 0xAB)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h45) begin
		$display("*** (%t) failed output value wrong (%x != 0x45)", $time, pc_o); #100 $stop;
	end

    // Loading ctrl clears outputs

	pia8255_wr(3, 8'h80);

    if(pa_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(0, 8'h10);
	pia8255_wr(1, 8'h20);
	pia8255_wr(2, 8'h30);

	if(pa_o != 8'h10) begin
		$display("*** (%t) failed output value wrong (%x != 0x10)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'h20) begin
		$display("*** (%t) failed output value wrong (%x != 0x20)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h30) begin
		$display("*** (%t) failed output value wrong (%x != 0x30)", $time, pc_o); #100 $stop;
	end

	// Enable/disable port output

	pia8255_wr(3, 8'h9B);
	pia8255_wr(0, 8'h01);
	pia8255_wr(1, 8'hAB);
	pia8255_wr(2, 8'h45);

	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(3, 8'h8B);
	pia8255_wr(0, 8'h01);
	pia8255_wr(1, 8'hAB);
	pia8255_wr(2, 8'h45);

	if(pa_o != 8'h01) begin
		$display("*** (%t) failed output value wrong (%x != 0x01)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(3, 8'h99);
	pia8255_wr(0, 8'h01);
	pia8255_wr(1, 8'hAB);
	pia8255_wr(2, 8'h45);

	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hAB) begin
		$display("*** (%t) failed output value wrong (%x != 0xAB)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(3, 8'h93);
	pia8255_wr(0, 8'h01);
	pia8255_wr(1, 8'hAB);
	pia8255_wr(2, 8'h45);

	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'h4F) begin
		$display("*** (%t) failed output value wrong (%x != 0x4F)", $time, pc_o); #100 $stop;
	end

	pia8255_wr(3, 8'h9A);
	pia8255_wr(0, 8'h01);
	pia8255_wr(1, 8'hAB);
	pia8255_wr(2, 8'h45);

	if(pa_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pa_o); #100 $stop;
	end
	if(pb_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pb_o); #100 $stop;
	end
	if(pc_o != 8'hF5) begin
		$display("*** (%t) failed output value wrong (%x != 0xF5)", $time, pc_o); #100 $stop;
	end

    // Set port C bits

    pia8255_wr(2, 8'h00);
    pia8255_wr(3, 8'h80);

	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h01);
	if(pc_o != 8'h01) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h03);
	if(pc_o != 8'h03) begin
		$display("*** (%t) failed output value wrong (%x != 0x03)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h05);
	if(pc_o != 8'h07) begin
		$display("*** (%t) failed output value wrong (%x != 0x07)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h07);
	if(pc_o != 8'h0F) begin
		$display("*** (%t) failed output value wrong (%x != 0x0F)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h09);
	if(pc_o != 8'h1F) begin
		$display("*** (%t) failed output value wrong (%x != 0x1F)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h0B);
	if(pc_o != 8'h3F) begin
		$display("*** (%t) failed output value wrong (%x != 0x3F)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h0D);
	if(pc_o != 8'h7F) begin
		$display("*** (%t) failed output value wrong (%x != 0x7F)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h0F);
	if(pc_o != 8'hFF) begin
		$display("*** (%t) failed output value wrong (%x != 0xFF)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h00);
	if(pc_o != 8'hFE) begin
		$display("*** (%t) failed output value wrong (%x != 0xFE)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h02);
	if(pc_o != 8'hFC) begin
		$display("*** (%t) failed output value wrong (%x != 0xFC)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h04);
	if(pc_o != 8'hF8) begin
		$display("*** (%t) failed output value wrong (%x != 0xF8)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h06);
	if(pc_o != 8'hF0) begin
		$display("*** (%t) failed output value wrong (%x != 0xF0)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h08);
	if(pc_o != 8'hE0) begin
		$display("*** (%t) failed output value wrong (%x != 0xE0)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h0A);
	if(pc_o != 8'hC0) begin
		$display("*** (%t) failed output value wrong (%x != 0xC0)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h0C);
	if(pc_o != 8'h80) begin
		$display("*** (%t) failed output value wrong (%x != 0x80)", $time, pc_o); #100 $stop;
	end

    pia8255_wr(3, 8'h0E);
	if(pc_o != 8'h00) begin
		$display("*** (%t) failed output value wrong (%x != 0x00)", $time, pc_o); #100 $stop;
	end

  #100 $stop;

end

endmodule
