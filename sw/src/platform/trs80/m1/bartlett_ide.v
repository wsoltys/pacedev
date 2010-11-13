module ide(
	cpu_a,
	cpu_d,
	cpu_rst_n,
	cpu_in_n,
	cpu_in_2_n,
	cpu_out_n,
	cpu_out_2_n,
	cpu_rd_n,
	cpu_irq_n,
	ide_d,
	ide_a,
	ide_ior_n,
	ide_iow_n,
	ide_cs1x_n,
	ide_cs3x_n,
	ide_rst_n,
	ide_irq
);

	input [ 15 : 0 ] cpu_a;
	inout [ 7 : 0 ] cpu_d;
	input	cpu_rst_n;
	input	cpu_in_n;
	input	cpu_in_2_n;
	input	cpu_out_n;
	input	cpu_out_2_n;
	input	cpu_rd_n;
	output	cpu_irq_n;

	inout [ 15 : 0 ] ide_d;
	output [ 2 : 0 ] ide_a;
	output	ide_ior_n;
	output	ide_iow_n;
	output	ide_cs1x_n;
	output	ide_cs3x_n;
	output	ide_rst_n;
	input	ide_irq;

//	input [ 1 : 0 ] wrprot;

	parameter IRQ_BIT = 5;

	wire deven;
	wire srst;
//	wire [ 1 : 0 ] wpviol;

	// IDE address.
	assign ide_a = cpu_a[ 2 : 0 ];

	// IDE chip selects.
	assign ide_cs1x_n = !( deven && cpu_a[ 7 : 0 ] >= 8'hc8 && cpu_a[ 7 : 0 ] <= 8'hcf );
	assign ide_cs3x_n = !( deven && cpu_a[ 7 : 0 ] >= 8'hc6 && cpu_a[ 7 : 0 ] <= 8'hc7 );

	wire sel_ide = ( deven && cpu_a[ 7 : 0 ] >= 8'hc6 && cpu_a[ 7 : 0 ] <= 8'hcf );

	// IDE read/write controls.
	assign ide_ior_n = !( !cpu_in_2_n && sel_ide );
	assign ide_iow_n = !( !cpu_out_2_n && sel_ide /*&& !|wpviol*/ );

	// IDE reset.
	assign ide_rst_n = !( srst || !cpu_rst_n );

	// IDE data MSB write register.
	// Reset not needed but gives a smaller, faster implementation.
	reg [ 7 : 0 ] msb_out;
	always @( negedge cpu_rst_n or posedge cpu_out_n ) begin
	  if( !cpu_rst_n ) begin
	    msb_out <= 0;
	  end else if( cpu_a[ 7 : 0 ] == 8'hc3 ) begin
	    msb_out <= cpu_d;
	  end
	end

	// IDE write data.
	wire sctreg = ( cpu_a[ 2 : 0 ] == 3'b011 );
	wire [ 7 : 0 ] ide_dout = sctreg ? ( cpu_d + 1 ) : cpu_d;
	assign ide_d = !ide_ior_n ? 16'hzzzz : { msb_out, ide_dout };

	// IDE data MSB read register.
	// Reset not needed but seems to improve hold time.
	reg [ 7 : 0 ] msb_in;
	always @( negedge cpu_rst_n or posedge cpu_in_n ) begin
	  if( !cpu_rst_n ) begin
	    msb_in <= 0;
	  end else if( sel_ide ) begin
	    msb_in <= ide_d[ 15 : 8 ];
	  end
	end

	// Adapter control register.
	reg [ 7 : 0 ] actrl;
	always @( negedge cpu_rst_n or posedge cpu_out_n ) begin
	  if( !cpu_rst_n ) begin	
	    actrl <= 0;
	  end else if( cpu_a[ 7 : 0 ] == 8'hc1 ) begin
	    actrl <= cpu_d;
	  end
	end

	// Device enable.
	// Not really useful.
	assign deven = 1'b1;//actrl[ 3 ];

	// Soft reset.
	// IDE has its own soft reset mechanism.
	assign srst = 1'b0;//actrl[ 4 ];

/* Hardware write protect--not useful because:
     - Have to track device select bit (reg 8'hce bit 4) to determine which drive is being written.
     - But, soft reset command (or other, say vendor-specific) commands could change device select.
     - So, no reliable way to ensure my shadow of device select is correct.
	// Device select.
	reg devsel;
	always@( negedge cpu_rst_n or posedge cpu_out_n ) begin
	  if( !cpu_rst_n ) begin
	    devsel <= 1'b0;
	  end else if( cpu_a[ 7 : 0 ] == 8'hce ) begin
	    devsel <= cpu_d[ 4 ];
	  end
	end

	// Hardware write protect.
	// Prevent write to sector buffer.
	assign wpviol[ 1 ] = deven && cpu_a[ 7 : 0 ] == 8'hc8 && !devsel && wrprot[ 1 ];
	assign wpviol[ 0 ] = deven && cpu_a[ 7 : 0 ] == 8'hc8 && devsel && wrprot[ 0 ];

	// Write protect violation status bits.
	reg [ 1 : 0 ] wpstat;
	always @( negedge cpu_rst_n or posedge cpu_out_n ) begin
	  if( !cpu_rst_n ) begin
	    wpstat <= 2'b00;
	  end else if( wpviol[ 1 ] ) begin
	    wpstat[ 1 ] <= 1'b1;
	  end else if( wpviol[ 0 ] ) begin
	    wpstat[ 0 ] <= 1'b1;
	  end else if( cpu_a[ 7 : 0 ] == 8'hc0 ) begin
	    wpstat[ 1 ] <= wpstat[ 1 ] && !( cpu_d[ 2 ] == 1 );
	    wpstat[ 0 ] <= wpstat[ 0 ] && !( cpu_d[ 1 ] == 1 );
	  end
	end
*/

	// CPU interrupt.
	wire irq_en = actrl[ 0 ];
	assign cpu_irq_n = ( irq_en && ide_irq ) ? 1'b0 : 1'bz;
        wire isr_rd = !cpu_rd_n && ( cpu_a[ 15 : 5 ] == 11'b00110111111 ) && ( cpu_a[ 3 : 2 ] == 2'b00 );
	assign cpu_d[ IRQ_BIT ] = isr_rd ?  ( irq_en && ide_irq ) : 1'bz;

	// CPU read data select.
	reg[ 7 : 0 ] rdata;
	always @( cpu_a[ 3 : 0 ] /*or wrprot or wpstat*/ or ide_irq or actrl or msb_in or ide_d ) begin
	  if( cpu_a[ 3 : 0 ] == 4'h0 ) begin
	    // Adapter status register.
//	    rdata = { wrprot, 3'b000, wpstat, ide_irq };
	    rdata = { 7'b0, ide_irq };
	  end else if( cpu_a[ 3 : 0 ] == 4'h1 ) begin
	    // Adapter control register.
	    rdata = actrl;
	  end else if( cpu_a[ 3 : 0 ] == 4'h2 ) begin
	    // Adapter device present register.
	    rdata = 8'h01;
	  end else if( cpu_a[ 3 : 0 ] == 4'h3 ) begin
	    // IDE data MSB read register.
	    rdata = msb_in;
	  end else if( cpu_a[ 3 : 0 ] == 4'hb ) begin
	    // IDE sector number register.
	    rdata = ide_d[ 7 : 0 ] - 1;
	  end else if( cpu_a[ 3 : 0 ] >= 4'h6 && cpu_a[ 3 : 0 ] <= 4'hf ) begin
	    // Other IDE control and command registers.
	    rdata = ide_d[ 7 : 0 ];
	  end else begin
	    // Reserved registers.
	    rdata = 8'h00;
	  end
	end

	// CPU read data.
	assign cpu_d = ( !cpu_in_2_n && cpu_a[ 7 : 4 ] == 4'hc ) ? rdata : 8'hzz;

endmodule

