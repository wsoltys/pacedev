module user_io_w(
	input      		SPI_CLK,
	input      		SPI_SS_IO,
	output     		SPI_MISO,
	input      		SPI_MOSI,
	
	output [5:0] 	JOY0,
	output [5:0] 	JOY1,
	output [1:0] 	BUTTONS,
	output [1:0] 	SWITCHES,

	output [7:0]   status,
	
	input 	  		clk,
	output	 		ps2_clk,
	output  		ps2_data
);


// the configuration string is returned to the io controller to allow
// it to control the menu on the OSD 
parameter CONF_STR = {
	"GAMEBOY;GB;"
};
parameter CONF_STR_LEN = 11;

user_io #(.STRLEN(CONF_STR_LEN)) user_io(
	.conf_str		( CONF_STR     ),

	// the spi interface
   .SPI_CLK     	(SPI_CLK			),
   .SPI_SS_IO   	(SPI_SS_IO		),
   .SPI_MISO    	(SPI_MISO			),   // tristate handling inside user_io
   .SPI_MOSI    	(SPI_MOSI			),
   
   .core_type    (8'ha4),

   .SWITCHES 		(SWITCHES		),
   .BUTTONS 		(BUTTONS			),

	// two joysticks supports
	.JOY0				(JOY0    ),
	.JOY1				(JOY1    ),

	// status byte (bit 0 = io controller reset)
	.status			( status       ),

	// ps2 keyboard interface
	.clk				(clk			),   // should be 10-16kHz for ps2 clock
	.ps2_data      (ps2_data		),
	.ps2_clk       (ps2_clk  		)
);


endmodule