// issue basic 1-wire commands

// Write '0', pull bus low for 60uS, pull bus high, wait 1uS
// Write '1', pull bus low for 1uS then pull bus high for 60uS, wait 1uS
// Read Bit pull bus low for 1uS then let bus float for 12uS then sample bit, wait 50uS

module one_wire_commands(
	// avalon bus slave port
	s_clock,				// all 1-wire timing derived from s_clock
	s_reset,
	s_datain,
	s_dataout,
	s_read,
	s_write,
	s_chipselect,
	s_waitrequest,
	
	data,					// 1-wire bidirectional bus - needs 10k pullup resistor on IO pin
	bus_reset,				// initiate a 1-wire reset pulse
	no_device,				// no 1-wire device detected
	busy,					// busy flag
	rxdata);				// the last received data

//`include "functions.v"

parameter		sysclock = 24576000;
parameter		trstl = ((sysclock / 1000000) * 480) - 1;	// 480uS
parameter		trsth = ((sysclock / 1000000) * 480) - 1;	// 480uS
parameter		tpdh = ((sysclock / 1000000) * 60) - 1;		// 60uS
parameter		tpdl = ((sysclock / 1000000) * 240) - 1;	// 240uS
parameter		tlow0 = ((sysclock / 1000000) * 60) - 1;	// 60uS
parameter		tlow1 = ((sysclock / 1000000) * 1) - 1;		// 1uS
parameter		trec = ((sysclock / 1000000) * 1) - 1;		// 1uS
parameter		tslot = ((sysclock / 1000000) * 60) - 1;	// 60uS
parameter		tlowr = ((sysclock / 1000000) * 1) - 1;		// 1uS
parameter		trdv = ((sysclock / 1000000) * 12) - 1;		// 12uS
parameter		trelease = ((sysclock / 1000000) * 50) - 1;	// 50uS

parameter		WIDTH = 16; //log2(trstl);

// port definition for avalon interface
input					s_clock;
input					s_reset;
input	[7:0]			s_datain;
output	[7:0]			s_dataout;
input					s_read;
input					s_write;
input					s_chipselect;
output					s_waitrequest;

// 1-wire interface and status
inout					data;
input					bus_reset;
output					no_device;
output					busy;
output	[7:0]			rxdata;

reg		[7:0]			s_dataout;
reg						s_waitrequest;
reg						busy;
reg		[7:0]			rxdata;

// state machine definition
reg		[14:0]			fsm, next_state;
parameter				INIT = 0;
parameter				IDLE = 1;
parameter				WRITE = 2;
parameter				WRITE_ONE = 3;
parameter				WRITE_ONE_1 = 4;
parameter				WRITE_ZERO = 5;
parameter				WAIT_HIGH = 6;
parameter				READ = 7;
parameter				READ_BIT = 8;
parameter				READ_BIT_1 = 9;
parameter				READ_BIT_2 = 10;
parameter				RESET = 11;
parameter				RESET1 = 12;
parameter				RESET2 = 13;
parameter				RESET3 = 14;

// module signals
reg		[1:0]			s_reset_sample;
reg						data_oe;
reg						data_reg, data_reg_data;
reg		[WIDTH - 1:0]	counter;
reg		[7:0]			xmitdata, xmitdata_data;
reg		[3:0]			bitcount, bitcount_data;
reg		[1:0]			data_sample;
reg						no_device, no_device_data;

// module control signals
reg						data_oe_ena, data_oe_data;
reg						data_reg_ena;
reg						counter_sclr;
reg						xmitdata_sload, xmitdata_rshift;
reg						rxdata_rshift;
reg						bitcount_ena, bitcount_sload;
reg						no_device_ena;

// handle driving the 1-wire bus
assign data = (data_oe) ? data_reg : 1'bz;

// synchronous process
always @ (posedge s_clock)
		s_reset_sample <= {s_reset_sample[0], s_reset};

always @ (posedge s_clock) begin
	if(s_reset_sample[1])
		begin
			data_oe <= 1'b0;
			data_reg <= 1'b0;
			counter <= 16'h0;
			bitcount <= 4'h0;
			xmitdata <= 8'h0;
			data_sample <= 2'b0;
			fsm <= INIT;
		end
	else
		begin
			data_sample <= {data_sample[0], data};
			fsm <= next_state;
			if(data_oe_ena)
				data_oe <= data_oe_data;
			if(data_reg_ena)
				data_reg <= data_reg_data;
			if(counter_sclr)						// counter control signals
				counter <= 0;
			else
				counter <= counter + 1;
			if(xmitdata_sload)						// transmit register control signals
				xmitdata <= xmitdata_data;
			else
				if(xmitdata_rshift)
					xmitdata <= {1'b0, xmitdata[7:1]};
			if(rxdata_rshift)
				rxdata <= {data_sample[1], rxdata[7:1]};
			if(bitcount_sload)						// bitcounter control signals
				bitcount <= bitcount_data;
			else
				if(bitcount_ena)
					bitcount <= bitcount + 4'h1;
			if(no_device_ena)
				no_device <= no_device_data;
	end
end

// asynchronous decoding
always @ (fsm, counter, bitcount, s_datain, s_write, s_read, s_chipselect, bus_reset, rxdata, xmitdata, data_sample) begin
	// default ports
	s_dataout = 8'h0;
	s_waitrequest = 1'b0;
	busy = 1'b0;
	//default signals
	data_oe_ena = 1'b0;
	data_oe_data = 1'b0;
	data_reg_data = 1'b0;
	data_reg_ena = 1'b0;
	bitcount_ena = 1'b0;
	bitcount_sload = 1'b0;
	bitcount_data = 4'h0;
	counter_sclr = 1'b0;
	xmitdata_rshift = 1'b0;
	xmitdata_sload = 1'b0;
	xmitdata_data = 8'h0;
	rxdata_rshift = 1'b0;
	no_device_data = 1'b0;
	no_device_ena = 1'b0;
	next_state = fsm;
	// decode state machine
	case (fsm)

		// initialise 1-wire bus
		INIT : begin
			busy = 1'b1;
			data_oe_data = 1'b0;				// tri-state
			data_oe_ena = 1'b1;
			if(counter >= trstl) begin		// allow settle time
				counter_sclr = 1'b1;			// clear the counter
				next_state = IDLE;
			end
			else
				next_state = INIT;
		end
		
		// wait for a command main branching point for FSM
		IDLE : begin
			data_reg_data = 1'b0;				// preset the data to drive out as '0'
			data_reg_ena = 1'b1;
			xmitdata_data = s_datain;
			bitcount_data = 4'h0;
			bitcount_sload = 1'b1;
			if(s_write && s_chipselect) begin
				busy = 1'b1;
				xmitdata_sload = 1'b1;			// enable the master data into transmit register
				next_state = WRITE;				// proceed on to perform the write function
			end
			else
				if(s_read && s_chipselect) begin
					busy = 1'b1;
					next_state = READ;
				end
			else
				if(bus_reset) begin
          counter_sclr = 1'b1;
					busy =1'b1;
					next_state = RESET;
				end
				else
					next_state = IDLE;
		end
		
		// write command
		WRITE : begin
			counter_sclr = 1'b1;				// pre-clear the timing counter
			busy = 1'b1;
			if(bitcount == 8)					// if we have shifted out all the data, go back and wait
				next_state = IDLE;
			else begin
				if(xmitdata[0])					// get the LS bit, do we write a 1 or 0?
					next_state = WRITE_ONE;
				else
					next_state = WRITE_ZERO;
			end
		end
		
		WRITE_ONE : begin
			busy = 1'b1;						// we are busy
			data_reg_data = 1'b1;
			data_oe_data = 1'b1;				// drive the bus with '0' (level preset in IDLE)
			data_oe_ena = 1'b1;
			if(counter == tlow1) begin			// when we have reached the count,
				counter_sclr = 1'b1;			// clear the timing counter
				data_reg_ena = 1'b1;			// enable the data register and drive high
				next_state = WRITE_ONE_1;		// proceed on to drive bus high
			end
			else
				next_state = WRITE_ONE;
		end

		WRITE_ONE_1 : begin
			busy = 1'b1;
			data_oe_data = 1'b0;				// tri-state
			if(counter == tslot) begin
				counter_sclr = 1'b1;
				data_oe_ena = 1'b1;				// enable tri-state at then end of slot
				next_state = WAIT_HIGH;
			end
			else
				next_state = WRITE_ONE_1;
		end

		WRITE_ZERO : begin
			busy = 1'b1;
			data_oe_data = 1'b1;				// drive bus
			data_oe_ena = 1'b1;
			if(counter == tlow0) begin
				counter_sclr = 1'b1;
				next_state = WAIT_HIGH;
			end
			else
				next_state = WRITE_ZERO;
		end

		WAIT_HIGH : begin						// common exit point for WRITE_ONE and WRITE_ZERO
			data_reg_data = 1'b0;
			data_reg_ena = 1'b1;
			data_oe_data = 1'b0;				// tri-state
			data_oe_ena = 1'b1;
			busy = 1'b1;
			if(counter == trec) begin
				bitcount_ena = 1'b1;
				xmitdata_rshift = 1'b1;
				next_state = WRITE;
			end
			else
				next_state = WAIT_HIGH;
		end
		
		// read command
		READ : begin
			busy = 1'b1;
			counter_sclr = 1'b1;
			if(bitcount == 8)
				next_state = IDLE;
			else
				next_state = READ_BIT;
		end
		
		READ_BIT : begin
			busy = 1'b1;
			data_oe_ena = 1'b1;
			data_reg_ena = 1'b1;
			data_reg_data = 1'b0;
			if(counter == tlowr) begin
				data_oe_data = 1'b0;
				counter_sclr = 1'b1;
				next_state = READ_BIT_1;
			end
			else begin
				data_oe_data = 1'b1;
				next_state = READ_BIT;
			end
		end
		
		READ_BIT_1 : begin
			busy = 1'b1;
			if(counter == trdv) begin
				rxdata_rshift = 1'b1;
				counter_sclr = 1'b1;
				next_state = READ_BIT_2;
			end
			else
				next_state = READ_BIT_1;
		end
		
		READ_BIT_2 : begin
			busy = 1'b1;
			if(counter == trelease) begin
				bitcount_ena = 1'b1;
				next_state = READ;
			end
			else
				next_state = READ_BIT_2;
		end
		
		// reset one wire bus command
		RESET : begin
			data_reg_data = 1'b0;
			data_reg_ena = 1'b1;
			data_oe_data = 1'b1;
			data_oe_ena = 1'b1;
			busy = 1'b1;
			if(counter == trstl) begin
				counter_sclr= 1'b1;
				next_state = RESET1;
			end
			else
				next_state = RESET;
		end
		
		RESET1 : begin
			data_oe_data = 1'b0;
			data_oe_ena = 1'b1;
			busy = 1'b1;
			if(counter == tpdh) begin
				counter_sclr = 1'b1;
				next_state = RESET2;
			end
			else
				next_state = RESET1;
		end
		
		RESET2 : begin
			busy = 1'b1;
			if(counter == tpdl) begin
				no_device_data = 1'b1;
				no_device_ena = 1'b1;
				next_state = IDLE;
			end
			else begin
				no_device_data = 1'b0;
				if(data_sample[1])
					next_state = RESET2;
				else begin
					no_device_ena = 1'b1;
					next_state = RESET3;
				end
			end
		end
		
		RESET3 : begin
			busy = 1'b1;
			if(counter == trsth) begin
				counter_sclr = 1'b1;
				next_state = IDLE;
			end
			else
				next_state = RESET3;
		end
		
		default :
			next_state = INIT;
	endcase
end

endmodule
