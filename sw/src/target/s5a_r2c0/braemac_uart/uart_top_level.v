// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

// signal names with r_ are register f_ are signal (combinatorial)

// RESET LOGIC NOT DONE - NEED TO CONSIDER SYNCHRONOUS RESET BIT 15 OF CONTROL REGISTER!!!!

module uart_top_level(
	
	// avalon slave interface
	input	logic			s_clock,
	input	logic			s_reset,
	input	logic	[2:0]	s_address,
	input	logic	[15:0]	s_writedata,
	output	logic	[15:0]	s_readdata,
	input	logic			s_read,
	input	logic			s_write,
	output	logic			s_waitrequest,
	output	logic			s_irq,
	
	// port definition
	output	logic			txd_active,
	output	logic			txd,
	output	logic			txd_led,
	input	logic			rxd,
	output	logic			rxd_led,
	
	input	logic			cts,
	output	logic			rts);
	
			parameter		SYS_CLOCK = 24576000,
							BAUD_RATE = 9600,
							DATA_BITS = 8,
							HALF_STOP_BITS = 2,
							PARITY = 2,
							RX_BUF_DEPTH = 4,
							TX_BUF_DEPTH = 8,
							CTS_RTS_AVAIL = 1,
							FILTER_ENABLE = 1,
							LED_FLASHRATE_HZ = 1000000,
							AUTO_BAUD_DETECT_EDGES = 10,
							DEBUG = 0;
	
			localparam 		BAUD_DIVIDER = (((SYS_CLOCK / BAUD_RATE) + 8) / 16) - 1;
	
			// registers
			logic			r_txgo, r_txgoac, r_reset;
			logic			r_rxled, r_txled, r_rxman, r_txman, r_rts, r_ctsa, r_ctss, r_rtsa, r_rtss;
			logic			r_rts_sample, r_cts_sample;
			logic			r_rxgo, r_filt1, r_filt2, r_tovf, r_rrdy, r_rovf;
			logic			r_brdc, r_nf, r_be, r_pe, r_fe;
			logic			r_ibrdc, r_irovf, r_inf, r_ibe, r_ife, r_ipe, r_ictss, r_irtss, r_irrdy, r_itovf, r_itrdy, r_itxidle;
			logic	[7:0]	r_rxaddress1, r_rxaddress2, r_rxmask1, r_rxmask2;
			logic	[9:0]	r_rxrdy_level, r_txrdy_level, r_rdy_level;
			logic	[15:0]	r_baud_rate_divider, r_DATA_BITS, r_HALF_STOP_BITS;
			logic [1:0] r_PARITY, r_DATA_BITS_temp;
			
			// inter module signals
			logic			baud_ena_x_16, set_noise_bit, set_bit_error, set_framing_error, set_parity_error;
			logic			rxcomplete, rxdatavalid;
			logic			global_reset;
			logic	[15:0]	raw_data;
			
			// top level signals
			logic			f_baudgo, f_clear_txgo,  f_txidle, f_trdy, f_tovf, f_rovf, f_rxbufclr, f_txbufclr, f_write_data, f_data_read;
			logic			f_ctss, f_rtss, f_rrdy, f_address_mode, f_address_trigger;
			logic	[9:0]	f_txusedw, f_rxusedw;
			logic	[15:0]	f_data;


	// actual UART modules
	//
	
  // not for public consumption	
	
endmodule
