
module MMC_start_DE1_TOP
  (
   ////////////////////	Clock Input	 	////////////////////	 
   CLOCK_24,					//	24 MHz
   CLOCK_27,					//	27 MHz
   CLOCK_50,					//	50 MHz
   EXT_CLOCK,					//	External Clock
   ////////////////////	Push Button		////////////////////
   KEY,						//	Pushbutton[3:0]
   ////////////////////	DPDT Switch		////////////////////
   SW,						//	Toggle Switch[9:0]
   ////////////////////	7-SEG Dispaly	////////////////////
   HEX0,					//	Seven Segment Digit 0
   HEX1,					//	Seven Segment Digit 1
   HEX2,					//	Seven Segment Digit 2
   HEX3,					//	Seven Segment Digit 3
   ////////////////////////	LED		///////////////////////
   LEDG,					//	LED Green[7:0]
   LEDR,					//	LED Red[9:0]
   ////////////////////////	UART	////////////////////////
   UART_TXD,					//	UART Transmitter
   UART_RXD,					//	UART Receiver
   /////////////////////	SDRAM Interface		////////////////
   DRAM_DQ,					//	SDRAM Data bus 16 Bits
   DRAM_ADDR,					//	SDRAM Address bus 12 Bits
   DRAM_LDQM,					//	SDRAM Low-byte Data Mask 
   DRAM_UDQM,					//	SDRAM High-byte Data Mask
   DRAM_WE_N,					//	SDRAM Write Enable
   DRAM_CAS_N,					//	SDRAM Column Address Strobe
   DRAM_RAS_N,					//	SDRAM Row Address Strobe
   DRAM_CS_N,					//	SDRAM Chip Select
   DRAM_BA_0,					//	SDRAM Bank Address 0
   DRAM_BA_1,					//	SDRAM Bank Address 0
   DRAM_CLK,					//	SDRAM Clock
   DRAM_CKE,					//	SDRAM Clock Enable
   ////////////////////	Flash Interface		////////////////
   FL_DQ,					//	FLASH Data bus 8 Bits
   FL_ADDR,					//	FLASH Address bus 22 Bits
   FL_WE_N,					//	FLASH Write Enable
   FL_RST_N,					//	FLASH Reset
   FL_OE_N,					//	FLASH Output Enable
   FL_CE_N,					//	FLASH Chip Enable
   ////////////////////	SRAM Interface		////////////////
   SRAM_DQ,					//	SRAM Data bus 16 Bits
   SRAM_ADDR,					//	SRAM Address bus 18 Bits
   SRAM_UB_N,					//	SRAM High-byte Data Mask 
   SRAM_LB_N,					//	SRAM Low-byte Data Mask 
   SRAM_WE_N,					//	SRAM Write Enable
   SRAM_CE_N,					//	SRAM Chip Enable
   SRAM_OE_N,					//	SRAM Output Enable
   ////////////////////	SD_Card Interface	////////////////
   SD_DAT,					//	SD Card Data
   SD_DAT3,					//	SD Card Data 3
   SD_CMD,					//	SD Card Command Signal
   SD_CLK,					//	SD Card Clock
   ////////////////////	USB JTAG link	////////////////////
   TDI,  					// CPLD -> FPGA (data in)
   TCK,  					// CPLD -> FPGA (clk)
   TCS,  					// CPLD -> FPGA (CS)
   TDO,  					// FPGA -> CPLD (data out)
   ////////////////////	I2C		////////////////////////////
   I2C_SDAT,					//	I2C Data
   I2C_SCLK,					//	I2C Clock
   ////////////////////	PS2		////////////////////////////
   PS2_DAT,					//	PS2 Data
   PS2_CLK,					//	PS2 Clock
   ////////////////////	VGA		////////////////////////////
   VGA_HS,					//	VGA H_SYNC
   VGA_VS,					//	VGA V_SYNC
   VGA_R,   					//	VGA Red[3:0]
   VGA_G,	 				//	VGA Green[3:0]
   VGA_B,  					//	VGA Blue[3:0]
   ////////////////	Audio CODEC		////////////////////////
   AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
   AUD_ADCDAT,						//	Audio CODEC ADC Data
   AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
   AUD_DACDAT,					//	Audio CODEC DAC Data
   AUD_BCLK,					//	Audio CODEC Bit-Stream Clock
   AUD_XCK,					//	Audio CODEC Chip Clock
   ////////////////////	GPIO	////////////////////////////
   GPIO_0,					//	GPIO Connection 0
   GPIO_1					//	GPIO Connection 1
   );

   ////////////////////////	Clock Input	 	////////////////////////
   input	[1:0]	CLOCK_24;			//	24 MHz
   input [1:0] 		CLOCK_27;			//	27 MHz
   input 		CLOCK_50;			//	50 MHz
   input 		EXT_CLOCK;			//	External Clock
   ////////////////////////	Push Button		////////////////////////
   input [3:0] 		KEY;				//	Pushbutton[3:0]
   ////////////////////////	DPDT Switch		////////////////////////
   input [9:0] 		SW;				//	Toggle Switch[9:0]
   ////////////////////////	7-SEG Dispaly	////////////////////////
   output [6:0] 	HEX0;				//	Seven Segment Digit 0
   output [6:0] 	HEX1;				//	Seven Segment Digit 1
   output [6:0] 	HEX2;				//	Seven Segment Digit 2
   output [6:0] 	HEX3;				//	Seven Segment Digit 3
   ////////////////////////////	LED		////////////////////////////
   output [7:0] 	LEDG;				//	LED Green[7:0]
   output [9:0] 	LEDR;				//	LED Red[9:0]
   ////////////////////////////	UART	////////////////////////////
   output 		UART_TXD;			//	UART Transmitter
   input 		UART_RXD;			//	UART Receiver
   ///////////////////////		SDRAM Interface	////////////////////////
   inout [15:0] 	DRAM_DQ;			//	SDRAM Data bus 16 Bits
   output [11:0] 	DRAM_ADDR;			//	SDRAM Address bus 12 Bits
   output 		DRAM_LDQM;			//	SDRAM Low-byte Data Mask 
   output 		DRAM_UDQM;			//	SDRAM High-byte Data Mask
   output 		DRAM_WE_N;			//	SDRAM Write Enable
   output 		DRAM_CAS_N;			//	SDRAM Column Address Strobe
   output 		DRAM_RAS_N;			//	SDRAM Row Address Strobe
   output 		DRAM_CS_N;			//	SDRAM Chip Select
   output 		DRAM_BA_0;			//	SDRAM Bank Address 0
   output 		DRAM_BA_1;			//	SDRAM Bank Address 0
   output 		DRAM_CLK;			//	SDRAM Clock
   output 		DRAM_CKE;			//	SDRAM Clock Enable
   ////////////////////////	Flash Interface	////////////////////////
   inout [7:0] 		FL_DQ;				//	FLASH Data bus 8 Bits
   output [21:0] 	FL_ADDR;			//	FLASH Address bus 22 Bits
   output 		FL_WE_N;			//	FLASH Write Enable
   output 		FL_RST_N;			//	FLASH Reset
   output 		FL_OE_N;			//	FLASH Output Enable
   output 		FL_CE_N;			//	FLASH Chip Enable
   ////////////////////////	SRAM Interface	////////////////////////
   inout [15:0] 	SRAM_DQ;			//	SRAM Data bus 16 Bits
   output [17:0] 	SRAM_ADDR;			//	SRAM Address bus 18 Bits
   output 		SRAM_UB_N;			//	SRAM High-byte Data Mask 
   output 		SRAM_LB_N;			//	SRAM Low-byte Data Mask 
   output 		SRAM_WE_N;			//	SRAM Write Enable
   output 		SRAM_CE_N;			//	SRAM Chip Enable
   output 		SRAM_OE_N;			//	SRAM Output Enable
   ////////////////////	SD Card Interface	////////////////////////
   inout 		SD_DAT;				//	SD Card Data
   inout 		SD_DAT3;			//	SD Card Data 3
   inout 		SD_CMD;				//	SD Card Command Signal
   output 		SD_CLK;				//	SD Card Clock
   ////////////////////////	I2C		////////////////////////////////
   inout 		I2C_SDAT;			//	I2C Data
   output 		I2C_SCLK;			//	I2C Clock
   ////////////////////////	PS2		////////////////////////////////
   input 		PS2_DAT;			//	PS2 Data
   input 		PS2_CLK;			//	PS2 Clock
   ////////////////////	USB JTAG link	////////////////////////////
   input 		TDI;				// CPLD -> FPGA (data in)
   input 		TCK;				// CPLD -> FPGA (clk)
   input 		TCS;				// CPLD -> FPGA (CS)
   output 		TDO;				// FPGA -> CPLD (data out)
   ////////////////////////	VGA			////////////////////////////
   output 		VGA_HS;				//	VGA H_SYNC
   output 		VGA_VS;				//	VGA V_SYNC
   output [3:0] 	VGA_R;   			//	VGA Red[3:0]
   output [3:0] 	VGA_G;	 			//	VGA Green[3:0]
   output [3:0] 	VGA_B;   			//	VGA Blue[3:0]
   ////////////////////	Audio CODEC		////////////////////////////
   inout 		AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
   input 		AUD_ADCDAT;			//	Audio CODEC ADC Data
   inout 		AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
   output 		AUD_DACDAT;			//	Audio CODEC DAC Data
   inout 		AUD_BCLK;			//	Audio CODEC Bit-Stream Clock
   output 		AUD_XCK;			//	Audio CODEC Chip Clock
   ////////////////////////	GPIO	////////////////////////////////
   inout [35:0] 	GPIO_0;				//	GPIO Connection 0
   inout [35:0] 	GPIO_1;				//	GPIO Connection 1

   assign 		LEDR		=	{kbd_available, 1'h0,  MMC_data};

   //	All inout port turn to tri-state
   assign 		DRAM_DQ		=	16'hzzzz;
   assign 		SRAM_DQ		=	16'hzzzz;
   assign 		SD_DAT		=	1'bz;
   assign 		I2C_SDAT	=	1'bz;
   assign 		AUD_ADCLRCK	=	1'bz;
   assign 		AUD_DACLRCK	=	1'bz;
   assign 		AUD_BCLK	=	1'bz;
   assign 		GPIO_0		=	{track, disk_phase};
   
//			36'hzzzzzzzzz; //{28'hzzzzzzz, sample_high8};
   assign 		GPIO_1		=	
					{
					 mclk28,
					 7'hzz, 
					 SW[8]? {4'b0, MMC_addr } : 	
					 mmc_mode_mem_addr,  // 18 bits
					 1'bz,		// first 10
					 z80_cen,
					 cpu_oe,
					 z80_cpu_we_n,
					 1'b0,
					 1'b0,					 
					 SD_DAT,						
					 SD_DAT3,					
					 SD_CMD,						
					 SD_CLK,	
					 };

//	Audio
//assign	AUD_ADCLRCK	=	AUD_DACLRCK;
//assign	AUD_XCK		=	AUD_CTRL_CLK;


   assign FL_WE_N = 1;
   assign FL_RST_N = 1;
   assign FL_OE_N	=  mem_ce_n_6502;
   assign FL_CE_N	= ~reading_flash;
   assign FL_WE_N	= 1'b1;
   assign FL_DQ		= 8'hzz;
   assign FL_ADDR = address_is_rom  ? {5'b0, 16'h1000 + cpu_addr[13:0]} : 
		   {5'b0, 16'h0000 + cpu_addr[13:0]}; //slot rom


//assign LEDG = {1'b0, A16ram, DL};
   assign      LEDG		=	{1'b0, disk_phase, card_status}; //mJTAG_DATA_FROM_HOST[7:0];   
   
   wire        reading_flash = (address_is_rom && ~card_ram_rd) || address_is_slot_rom;
   wire   mclk28;
   wire [7:0] mem_data;
   wire [7:0] io_data;

   wire       m1_n;
   wire [15:0] mSEG7_DIG;
   wire        reset_in = ~CPU_reset_n; 
   wire        CPU_reset_n = locked_sig && KEY[0];  
   wire [12:0] video_addr;
   wire        ROM_address_space;

   wire [15:0] cpu_addr; //6502
   wire [7:0]  cpu_di;
   wire [7:0]  cpu_do;
   wire        cpu_rom_access;
   wire        cpu_ram_access;
   wire        video_has_bus;
   wire [17:0] ram_addr;
   wire        turbo;
   assign      turbo = 0;
   wire [5:0]  DL;
   wire        vga_oe, cpu_oe; 
   wire        cpu_clock_en;
   wire [4:0]  scan_res; //from keyboard

   assign      vga_oe = ~video_has_bus; 

`define HAS_z80CPU
//`define HAS_SOUND

  assign SRAM_DQ[15:8] = 8'bz; 

// clock is 28.56 mHz - close enough to double the Apple master clock
   pll pll_50_to_28 (.inclk0(CLOCK_50),	.c0(mclk28),.locked(locked_sig));
   
   SEG7_LUT_4 			u0	(	HEX0,HEX1,HEX2,HEX3,mSEG7_DIG );
   
   assign mSEG7_DIG = SW[2] ? cpu_addr : {2'b0, track, SRAM_DQ[7:0]};
	
   wire        int_n, nmi_n, busrq_n;
   assign      int_n = 1;//~interrupt;
   assign      nmi_n = 1;
   assign      busrq_n = 1;
   wire [4:0]  BusCycle;
   wire [6:0]  CounterX; // 0x40 to 0x7f
   wire [9:0]  CounterY;
//   reg [7:0]   video_mem_data;
   wire        LDPS =  (BusCycle == 3) || (BusCycle == 17); //
   wire        memory_access_time = (BusCycle == 3) || (BusCycle == 2) ||
		 (BusCycle == 17) || (BusCycle == 16) || (BusCycle == 7) || (BusCycle == 8);
  
  
   wire [3:0]  addr_sum = {~CounterX[5],~CounterX[5],CounterX[4],CounterX[3]} + 
	       {CounterY[8],CounterY[7],CounterY[8],CounterY[7]} + 1;

  // wire        GR = ~(TEXT || ( MIXED &&  CounterY[6] && CounterY[8]));

   reg 	       TEXT,MIXED,HIRES, mode_80COL,mode_80STORE;
   reg 	       RAMRD, RAMWRT, ALTZP;
   reg 	       AltCharSet, PAGE2;
   wire [6:0]  high_vid_addr;
   assign      high_vid_addr = (HIRES & GR) ? {2'b00, PAGE2, ~PAGE2, CounterY[3:1]} : 
	       {5'b00000, PAGE2, ~PAGE2}	;

   wire [15:0] apple_video_addr =  {high_vid_addr, CounterY[6:4], addr_sum ,CounterX[2:0]};
   wire [15:0] final_ram_addr;

   wire io_access = (cpu_addr[15:8] == 8'b11000000);
   reg 	cpu_write_cycle;
   
   always @(posedge mclk28) 
     if(reset_in) begin
	PAGE2 <= 0;
	HIRES <= 0;
	AltCharSet <= 0;
	mode_80COL <= 0;
	TEXT <= 1;	
     end  else begin
	if((BusCycle == 7) && io_access)begin
	   if(~rw_6502) begin			// writes that switch
	      case(cpu_addr[7:0])
		8'h00: mode_80STORE <= 0;
		8'h01: mode_80STORE <= 1;
		8'h02: RAMRD <= 0;
		8'h03: RAMRD <= 1;				
		8'h04: RAMWRT <= 0;
		8'h05: RAMWRT <= 1;				
		8'h08: ALTZP <= 0;
		8'h09: ALTZP <= 1;				

		8'h0C: 	mode_80COL <= 0;
		8'h0D:	mode_80COL <= 1;
		
		8'h0E: 	AltCharSet <= 0;
		8'h0F:	AltCharSet <= 1;

	      endcase
	   end else begin			// reads that switch
	      
	      case(cpu_addr[7:0])
		8'h50:		TEXT <= 0;
		8'h51:		TEXT <= 1;

		8'h52:		MIXED <= 0;
		8'h53:		MIXED <= 1;

		8'h54:		PAGE2 <= 0;
		8'h55:		PAGE2 <= 1;

		8'h56:		HIRES <= 0;
		8'h57:		HIRES <= 1;
	      endcase
	   end
	end
     end


// the 6502 side of the floppy disk interface

   reg odd_access = 0;

   // RWTS likes the disk data to change so it knows the disk is turning
   // so we'll feed it 0 every other byte
   always @ (posedge mclk28)
     if(read_disk_data)
       odd_access <= ~odd_access;
 
   
   
   wire c6_io	=	(cpu_addr[15:4] == 12'hc0e) && (BusCycle == 8);	// c0ex   
   wire read_disk_data = (cpu_addr == 'hC0EC) & (BusCycle == 8);
   wire [12:0] disk_ram_addr;  
   wire [5:0]  track;
   wire [3:0]  disk_phase;
   wire [7:0]  disk_buff_do;
  
   
   disk disk_intf (
		   .mclk28(mclk28), 
		   .read_disk_data(read_disk_data  & odd_access), 
		   .c6_io(c6_io), 
		   .reset(reset_in), 
		   .addr(cpu_addr[7:0]), 
		   .wr(rw_6502), 
		   .ram_addr(disk_ram_addr), 
		   .track(track),
		   .disk_phase(disk_phase)
		   );


   // 6502 CPU

   clock_ctrl	clock_ctrl_inst (
	.ena (  ( BusCycle == 8) && ~mmc_mode ),
	.inclk ( mclk28 ),
	.outclk ( cpuclk_6502 )
	);

   
   
  // wire cpuclk_6502 = ( BusCycle == 8) && ~mmc_mode;
   
   reg 	nmi_6502 = 0;
   reg 	irq_6502 = 0;
   wire rdy_6502 = 1;
   wire [7:0] ram_dat = reading_flash  ? FL_DQ : SRAM_DQ ;


   wire [7:0]  floppy_data = odd_access ? disk_buff_do : 8'h0;
   
   wire [7:0] di_6502 = apple_kbd_access ? {kbd_available, kbd_ascii} :
	      (cpu_addr == 'hC0EC) ? floppy_data :
	      ram_dat;
   
   wire [7:0] do_6502;
   //wire       mem_rw_6502 = ~((BusCycle == 7) && cpu_write_cycle);
   wire       mem_rw_6502 = ~((BusCycle == 7) && ~rw_6502);

   
   wire       cpu_access_time =  (BusCycle == 7) || (BusCycle == 8);
   wire       mem_ce_n_6502 = ~memory_access_time;
   
   
   bc6502 cpu0(.reset(reset_in || ~KEY[3]), 
	       .clk(cpuclk_6502), 
	       .nmi(nmi_6502), 
	       .irq(irq_6502),
	       .rdy(rdy_6502), 
	       .di(di_6502), 
	       .do(do_6502),
	       .rw(rw_6502), 
	       .ma(cpu_addr), 
	       .sync(sync) );

   // RAM card logic
   assign card_status = {card_ram_we, card_ram_rd, bank1};

   ramcard ramcard (
		    .mclk28(mclk28), 
		    .reset_in(reset_in || ~KEY[3]), 
		    .strobe(BusCycle == 7), 
		    .addr(cpu_addr), 
		    .ram_addr(final_ram_addr), 
		    .we(~rw_6502), 
		    .card_ram_we(card_ram_we), 
		    .card_ram_rd(card_ram_rd), 
		    .bank1(bank1)
		    );


   
   // VIDEO section
   wire [3:0] R;
   wire [3:0] G;
   wire [3:0] B;

   assign      VGA_R = (HBL2 || VBL1) ? 0: R;
   assign      VGA_G = (HBL2 || VBL1) ? 0: G;
   assign      VGA_B = (HBL2 || VBL1) ? 0: B;

   reg 	       HBL1,HBL2, VBL1;
	
   wire [5:0]  hor_addr = (CounterX - 7'h58);
   wire [7:0]	 video_mem_data = {( mmc_mode ? 1'b1: video_high_bit), SRAM_DQ[6:0]};
   wire 	 video_high_bit = SRAM_DQ[7];
   

   always @(posedge mclk28) begin
      if(BusCycle == 8) begin
	  cpu_write_cycle <= (rw_6502 == 0);
      end
 	
      if(LDPS) begin
	 	HBL1 <= HBL;
	 	HBL2 <= HBL1;
		VBL1 <= VBL;
//	 video_mem_data <= SRAM_DQ[7:0]; 
      end	
   end
	
   AppleShifter 
     shifter (
	      .clk28(mclk28), 
	      .CounterY(CounterY), 
	      .do_shift(BusCycle[0]),
	      .odd_dot(BusCycle[1]),
	      .LDPS(LDPS), 
	      .ram_data(video_mem_data), 
	      .pixelout(pixelout),
		  .GR(GR),
	      .vga_R(R),
	      .vga_G(G),
	      .vga_B(B),
	      .TEXT(TEXT), 
	      .MIXED(MIXED),
	      .HIRES(HIRES),
	      .AltCharSet(AltCharSet),
	      .flash_count4(flash_count4)	      
	      );
   
   AppleVideoTiming
	AppleVideoTiming (
			  .clk28(mclk28), 
			  .reset_in(~CPU_reset_n),
			  .vga_HS(VGA_HS), 
			  .vga_VS(VGA_VS),
			  .BusCycle(BusCycle),
			  .CounterX(CounterX),
			  .CounterY(CounterY),
			  .HBL(HBL), 
			  .VBL(VBL), 
			  .flash_count4(flash_count4)
			  );


	
   wire 		mmc_mode = SW[1] & mmc_load_mode;	
   wire [17:0] 		mmc_mode_mem_addr;
   wire [15:0] 		z80_cpu_addr;
   wire [7:0] 		z80_cpu_di;
   wire [7:0] 		z80_cpu_do;
   wire 		z80_cen =  ( BusCycle == 8) && mmc_mode;
			// (BusCycle[2:0] == 3'b111);
//			(BusCycle[2:0] == 3'b010);
   wire 		z80_write_time =   (BusCycle[2:1] == 2'b11);
				      
   // D000 and up
   wire 		address_is_rom = cpu_addr[15] && cpu_addr[14] &&
			(cpu_addr[13] || cpu_addr[12]);

   wire 		address_is_slot_rom = (cpu_addr[15:8] == 8'hC6); //only disk ROM present
   wire 		address_is_ram = (cpu_addr[15:14] == 2'b00);
      
   wire 		ram_card_read = address_is_rom & card_status[1];
   wire 		ram_card_write = address_is_rom & card_status[2];
   wire [2:0] 		card_status;

   assign SRAM_UB_N = 1'b1;
   assign SRAM_LB_N = 1'b0;

   wire cpu_ram_oe = mmc_mode ?  ~cpu_oe :
//	( cpu_access_time && ~cpu_write_cycle);
	( cpu_access_time && rw_6502);
   
   
   assign SRAM_OE_N =   ~(LDPS || (cpu_ram_oe && ~reading_flash));
   
   assign SRAM_CE_N = mmc_mode ? 0 :  //always on
	  mem_ce_n_6502; //Apple mode

   assign ram_addr =   LDPS ? {2'b00, apple_video_addr} : {2'b00, final_ram_addr};
   assign SRAM_ADDR = mmc_mode ?  mmc_mode_mem_addr : ram_addr;

// video memory mapped to 0x4000 in z80 space
   assign mmc_mode_mem_addr = z80_cen  ? {2'b01,z80_cpu_addr} :
	  //z80_write_time ? {2'b01,z80_cpu_addr} :
	  LDPS ? {2'b01,4'b0100, apple_video_addr[11:0]} : 18'h0;
	
`ifdef HAS_z80CPU
   wire        mreq_n, iorq_n; 
   wire        cpu_wt;
   wire        wait_n = 1;			

   assign cpu_oe = mreq_n | cpu_rd | ~rfsh_n | ~z80_cen; // all low -> low
   assign io_data =  z80_cpu_addr[7:0] == 8'hab ? {7'h0, SPI_active} : 
	  z80_cpu_addr[7:0] == 8'h00 ? {kbd_available, kbd_ascii} : 8'h00;
   
   assign SRAM_DQ[7:0] =  (mmc_mode && ((mreq_n | cpu_wt) == 0) && z80_cen) ?  z80_cpu_do :
	  (~mem_rw_6502 && (~address_is_rom || ram_card_write)) ? do_6502 : 8'hzz; 
//	  (~(address_is_rom  | address_is_slot_rom) &&  mem_rw_6502) ?  do_6502 : 8'hzz; 
	    
       // we need to latch the di signal for this core
   reg [7:0] di_r1;
   always @(posedge mclk28) begin
      if(z80_cen) begin
	 if(mreq_n == 0)
	   di_r1 <=   mem_data;
	 if(iorq_n == 0)
	   di_r1 <= io_data;
      end
   end

   assign z80_cpu_di = di_r1 ;
	
   assign    ROM_address_space = ~(z80_cpu_addr[15] | z80_cpu_addr[14]);
   wire      RAM_address_space = (z80_cpu_addr[15] | z80_cpu_addr[14]);
   assign    mem_data = RAM_address_space ? SRAM_DQ[7:0] : low16k_data;
	
   wire      z80_cpu_we_n = 	mreq_n | cpu_wt | ~z80_cen ; // all low -> low

   assign    SRAM_WE_N =  mmc_mode ? z80_cpu_we_n | ROM_address_space :
	     ~(~mem_rw_6502 && (~address_is_rom || ram_card_write));

   tv80s z80cpu (
		 .m1_n(m1_n), 
		 .mreq_n(mreq_n), 
		 .iorq_n(iorq_n), 
		 .rd_n(cpu_rd), 
		 .wr_n(cpu_wt), 
		 .rfsh_n(rfsh_n), 
		 .halt_n(halt_n), 
		 .busak_n(busak_n), 
		 .A(z80_cpu_addr), 
		 .do(z80_cpu_do), 
		 .reset_n(CPU_reset_n), 
		 .clk(mclk28), 
		 .wait_n(wait_n), 
		 .int_n(int_n), 
		 .nmi_n(nmi_n), 
		 .busrq_n(busrq_n), 
		 .di(z80_cpu_di), 
		 .cen(z80_cen)
		 );

`else
   assign    cpu_oe = 1'b1;
`endif

   reg 	     mmc_load_mode; // z80 in control running mmc_fat_rom code
   wire [7:0] disk_data;
   wire [7:0] mmc_cpu_di;

   always @(posedge mclk28) begin
      if(reset_in || (KEY[1] == 0) )
	mmc_load_mode <= 1'b1;
      else begin
	 if(~iorq_n && (z80_cpu_addr[7:0] == 8'had) && ~cpu_wt)
	   mmc_load_mode <= 1'b0;
      end	 
   end   

   wire [15:0] disk_buff_addr = mmc_mode ? z80_cpu_addr : {3'b000, disk_ram_addr};
   
      
   mmc_disk mmc_disk (/*AUTOINST*/
		      // Outputs
		      .SD_DAT3		(SD_DAT3),
		      .SD_CMD		(SD_CMD),
		      .SD_CLK		(SD_CLK),
		      .mmc_read_kbd	(mmc_read_kbd),
		      .SPI_active	(SPI_active),
		      .disk_data	(disk_data[7:0]),
		      .MMC_addr		(MMC_addr[12:0]),
		      .MMC_data		(MMC_data[7:0]),
		      .z80_cpu_di	(mmc_cpu_di[7:0]),
		      // Inputs
		      .SD_DAT		(SD_DAT),
		      .z80_cen		(z80_cen),
		      .mreq_n		(mreq_n),
		      .track		(track[5:0]),
		      .mclk28		(mclk28),
		      .reset_in		(reset_in),
		      .iorq_n		(iorq_n),
		      .cpu_wt		(cpu_wt),
		      .z80_cpu_addr	(disk_buff_addr),
		      .z80_cpu_do	(z80_cpu_do[7:0]),

		      .mmc_init_mode(mmc_mode),
		      .disk_buff_do(disk_buff_do)
		      
		      );
   
	
   wire [7:0] MMC_data;
   wire [12:0] MMC_addr;	

//assign SD_DAT3 = ~SPI_control;


   wire [7:0] low16k_data = mmc_mode ? mmc_cpu_di : 8'h00;

//VGA_Audio_PLL 		u3	(	.inclk0(CLOCK_27[0]),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK)	);

   //***************************** keyboard intface ********************

   assign read_kbd = mmc_mode ? mmc_read_kbd : (cpu_addr == 16'hC010);
   wire apple_kbd_access = (cpu_addr[15:4] == 12'hC00);
   wire [6:0] kbd_ascii;
   

   kbd_intf kbd_intf (
    .mclk25(mclk28), 
    .reset_in(reset_in), 
    .PS2_Clk(PS2_CLK), 
    .PS2_Data(PS2_DAT), 
  //  .shift(shift), 
    .ascii(kbd_ascii), 
    .kbd_available(kbd_available), 
    .read_kb(read_kbd)
    );




endmodule