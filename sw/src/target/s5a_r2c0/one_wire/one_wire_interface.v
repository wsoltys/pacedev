module one_wire_interface(
	// avalon bus interface
	s_clock,
	s_reset,
	s_address,
	s_datain,
	s_dataout,
	s_read,
	s_write,
	s_chipselect,
	s_waitrequest,
	
	// one-wire bus
	data);

//`include "functions.v"

//parameter sysclock = 49152000;
parameter		sysclock = 66666667;

// port definitions for avalon interface
input			s_clock;
input			s_reset;
input	[3:0]	s_address;
input	[7:0]	s_datain;
output	[7:0]	s_dataout;
input			s_read;
input			s_write;
input			s_chipselect;
output			s_waitrequest;

// port definition for 1-wire interface
inout			data;

//
reg		[7:0]	s_dataout;
reg				s_waitrequest;

wire [7:0] o_w_dataout;
reg				o_w_chipselect;
wire      o_w_waitrequest;
reg				o_w_reset;
wire      o_w_no_device;
wire      o_w_busy;
wire [7:0]	o_w_rxdata;
one_wire_commands	one_wire(
					.s_clock(s_clock),
					.s_reset(s_reset),
					.s_datain(s_datain),
					.s_dataout(o_w_dataout),
					.s_read(s_read),
					.s_write(s_write),
					.s_chipselect(o_w_chipselect),
					.s_waitrequest(o_w_waitrequest),
					.data(data),
					.bus_reset(o_w_reset),
					.no_device(o_w_no_device),
					.busy(o_w_busy),
					.rxdata(o_w_rxdata));
defparam		one_wire.sysclock = sysclock;

always @ (s_address, s_write, s_chipselect, data, o_w_no_device, o_w_busy,
			o_w_waitrequest, o_w_dataout, o_w_reset, o_w_chipselect, o_w_rxdata) begin
	// default values
	s_dataout = 8'h0;
	s_waitrequest = 1'b0;
	o_w_reset = 1'b0;
	o_w_chipselect = 1'b0;
	case (s_address)
		// status register - write to this register to force a 1-wire reset
		4'h0 : begin
			o_w_reset = s_chipselect && s_write;
			s_dataout[2:0] = {data, o_w_no_device, o_w_busy};
			s_waitrequest = 1'b0;
		end
		
		// interface - read and write
		4'h1 : begin
			o_w_chipselect = s_chipselect;
			s_waitrequest = 1'b0;
			s_dataout = o_w_dataout;
		end
		
		// read the last data received
		4'h2 : begin
			s_dataout = o_w_rxdata;
		end
		
		default : begin
			s_waitrequest = 1'b0;
			s_dataout = 8'hdb;
		end
	endcase
end

endmodule
