library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.maple_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
		--////////////////////	Clock Input	 	////////////////////	 
		clock_27      : in std_logic;                         --	27 MHz
		clock_50      : in std_logic;                         --	50 MHz
		ext_clock     : in std_logic;                         --	External Clock
		--////////////////////	Push Button		////////////////////
		key           : in std_logic_vector(3 downto 0);      --	Pushbutton[3:0]
		--////////////////////	DPDT Switch		////////////////////
		sw            : in std_logic_vector(17 downto 0);     --	Toggle Switch[17:0]
		--////////////////////	7-SEG Dispaly	////////////////////
		hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
		hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
		hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
		hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
		hex4          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 4
		hex5          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 5
		hex6          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 6
		hex7          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 7
		--////////////////////////	LED		////////////////////////
		ledg          : out std_logic_vector(8 downto 0);     --	LED Green[8:0]
		ledr          : out std_logic_vector(17 downto 0);    --	LED Red[17:0]
		--////////////////////////	UART	////////////////////////
		uart_txd      : out std_logic;                        --	UART Transmitter
		uart_rxd      : in std_logic;                         --	UART Receiver
		--////////////////////////	IRDA	////////////////////////
		irda_txd      : out std_logic;                        --	IRDA Transmitter
		irda_rxd      : in std_logic;                         --	IRDA Receiver
		--/////////////////////	SDRAM Interface		////////////////
		dram_dq       : inout std_logic_vector(15 downto 0);  --	SDRAM Data bus 16 Bits
		dram_addr     : out std_logic_vector(11 downto 0);    --	SDRAM Address bus 12 Bits
		dram_ldqm     : out std_logic;                        --	SDRAM Low-byte Data Mask 
		dram_udqm     : out std_logic;                        --	SDRAM High-byte Data Mask
		dram_we_n     : out std_logic;                        --	SDRAM Write Enable
		dram_cas_n    : out std_logic;                        --	SDRAM Column Address Strobe
		dram_ras_n    : out std_logic;                        --	SDRAM Row Address Strobe
		dram_cs_n     : out std_logic;                        --	SDRAM Chip Select
		dram_ba_0     : out std_logic;                        --	SDRAM Bank Address 0
		dram_ba_1     : out std_logic;                        --	SDRAM Bank Address 0
		dram_clk      : out std_logic;                        --	SDRAM Clock
		dram_cke      : out std_logic;                        --	SDRAM Clock Enable
		--////////////////////	Flash Interface		////////////////
		fl_dq         : inout std_logic_vector(7 downto 0);   --	FLASH Data bus 8 Bits
		fl_addr       : out std_logic_vector(21 downto 0);    --	FLASH Address bus 22 Bits
		fl_we_n       : out std_logic;                        -- 	FLASH Write Enable
		fl_rst_n      : out std_logic;                        --	FLASH Reset
		fl_oe_n       : out std_logic;                        --	FLASH Output Enable
		fl_ce_n       : out std_logic;                        --	FLASH Chip Enable
		--////////////////////	SRAM Interface		////////////////
		sram_dq       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
		sram_addr     : out std_logic_vector(17 downto 0);    --	SRAM Address bus 18 Bits
		sram_ub_n     : out std_logic;                        --	SRAM High-byte Data Mask 
		sram_lb_n     : out std_logic;                        --	SRAM Low-byte Data Mask 
		sram_we_n     : out std_logic;                        --	SRAM Write Enable
		sram_ce_n     : out std_logic;                        --	SRAM Chip Enable
		sram_oe_n     : out std_logic;                        --	SRAM Output Enable
		--////////////////////	ISP1362 Interface	////////////////
		otg_data      : inout std_logic_vector(15 downto 0);  --	ISP1362 Data bus 16 Bits
		otg_addr      : out std_logic_vector(1 downto 0);     --	ISP1362 Address 2 Bits
		otg_cs_n      : out std_logic;                        --	ISP1362 Chip Select
		otg_rd_n      : out std_logic;                        --	ISP1362 Write
		otg_wr_n      : out std_logic;                        --	ISP1362 Read
		otg_rst_n     : out std_logic;                        --	ISP1362 Reset
		otg_fspeed    : out std_logic;                        --	USB Full Speed,	0 = Enable, Z = Disable
		otg_lspeed    : out std_logic;                        --	USB Low Speed, 	0 = Enable, Z = Disable
		otg_int0 			: in std_logic;                         --	ISP1362 Interrupt 0
		otg_int1 			: in std_logic;                         --	ISP1362 Interrupt 1
		otg_dreq0 		: in std_logic;                         --	ISP1362 DMA Request 0
		otg_dreq1 		: in std_logic;                         --	ISP1362 DMA Request 1
		otg_dack0_n   : out std_logic;                        --	ISP1362 DMA Acknowledge 0
		otg_dack1_n   : out std_logic;                        --	ISP1362 DMA Acknowledge 1
		--////////////////////	LCD Module 16X2		////////////////
		lcd_data      : inout std_logic_vector(7 downto 0);   --	LCD Data bus 8 bits
		lcd_on        : out std_logic;                        --	LCD Power ON/OFF
		lcd_blon      : out std_logic;                        --	LCD Back Light ON/OFF
		lcd_rw        : out std_logic;                        --	LCD Read/Write Select, 0 = Write, 1 = Read
		lcd_en        : out std_logic;                        --	LCD Enable
		lcd_rs        : out std_logic;                        --	LCD Command/Data Select, 0 = Command, 1 = Data
		--////////////////////	SD_Card Interface	////////////////
		sd_dat        : inout std_logic;                      --	SD Card Data
		sd_dat3       : inout std_logic;                      --	SD Card Data 3
		sd_cmd        : inout std_logic;                      --	SD Card Command Signal
		sd_clk        : out std_logic;                        --	SD Card Clock
		--////////////////////	USB JTAG link	////////////////////
		tdi           : in std_logic;                         -- CPLD -> FPGA (data in)
		tck           : in std_logic;                         -- CPLD -> FPGA (clk)
		tcs           : in std_logic;                         -- CPLD -> FPGA (CS)
	  tdo           : out std_logic;                        -- FPGA -> CPLD (data out)
		--////////////////////	I2C		////////////////////////////
		i2c_sdat      : inout std_logic;                      --	I2C Data
		i2c_sclk      : out std_logic;                        --	I2C Clock
		--////////////////////	PS2		////////////////////////////
		ps2_dat       : inout std_logic;                       --	PS2 Data
		ps2_clk       : inout std_logic;                       --	PS2 Clock
		--////////////////////	VGA		////////////////////////////
		vga_clk       : out std_logic;                        --	VGA Clock
		vga_hs        : out std_logic;                        --	VGA H_SYNC
		vga_vs        : out std_logic;                        --	VGA V_SYNC
		vga_blank     : out std_logic;                        --	VGA BLANK
		vga_sync      : out std_logic;                        --	VGA SYNC
		vga_r         : out std_logic_vector(9 downto 0);     --	VGA Red[9:0]
		vga_g         : out std_logic_vector(9 downto 0);     --	VGA Green[9:0]
		vga_b         : out std_logic_vector(9 downto 0);     --	VGA Blue[9:0]
		--////////////	Ethernet Interface	////////////////////////
		enet_data     : inout std_logic_vector(15 downto 0);  --	DM9000A DATA bus 16Bits
		enet_cmd      : out std_logic;                        --	DM9000A Command/Data Select, 0 = Command, 1 = Data
		enet_cs_n     : out std_logic;                        --	DM9000A Chip Select
		enet_wr_n     : out std_logic;                        --	DM9000A Write
		enet_rd_n     : out std_logic;                        --	DM9000A Read
		enet_rst_n    : out std_logic;                        --	DM9000A Reset
		enet_int      : in std_logic;                         --	DM9000A Interrupt
		enet_clk      : out std_logic;                        --	DM9000A Clock 25 MHz
		--////////////////	Audio CODEC		////////////////////////
		aud_adclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock
		aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
		aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
		aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
		aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
		aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
		--////////////////	TV Decoder		////////////////////////
		td_data       : in std_logic_vector(7 downto 0);      --	TV Decoder Data bus 8 bits
		td_hs         : in std_logic;                         --	TV Decoder H_SYNC
		td_vs         : in std_logic;                         --	TV Decoder V_SYNC
		td_reset      : out std_logic;                        --	TV Decoder Reset
		--////////////////////	GPIO	////////////////////////////
		gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
		gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
  );

end target_top;

architecture SYN of target_top is

	alias gpio_maple 		: std_logic_vector(35 downto 0) is gpio_0;
	alias gpio_lcd 			: std_logic_vector(35 downto 0) is gpio_1;
	
	signal reset				: std_logic;
	signal reset_n			: std_logic;
  signal init        	: std_logic;

  signal clk_24M      : std_logic;
  signal vga_hs_s     : std_logic;
  signal vga_vs_s     : std_logic;
  signal dram_clk_s   : std_logic;

  signal ps2_mclk     : std_logic;
  signal ps2_mdat     : std_logic;

	signal jamma				: JAMMAInputsType;

	-- maple/dreamcast controller interface
	signal maple_sense	: std_logic;
	signal maple_oe			: std_logic;
	signal mpj					: work.maple_pkg.joystate_type;

	-- gamecube controller interface
	signal gcj						: work.gamecube_pkg.joystate_type;
			
begin

	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock_50)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(clock_50) then
			if count = X"FFF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;
  reset <= init or not sw(0);

  -- *MUST* be high to use 27MHz clock as input
  td_reset <= '1';

	assert (not (DE2_JAMMA_IS_MAPLE and DE2_JAMMA_IS_GAMECUBE))
		report "Cannot choose both MAPLE and GAMECUBE interfaces"
		severity error;
	
	GEN_MAPLE : if DE2_JAMMA_IS_MAPLE generate
	
		-- Dreamcast MapleBus joystick interface
		MAPLE_JOY_inst : maple_joy
			port map
			(
				clk				=> clock_50,
				reset			=> reset,
				sense			=> maple_sense,
				oe				=> maple_oe,
				a					=> gpio_maple(14),
				b					=> gpio_maple(13),
				joystate	=> mpj
			);
		gpio_maple(12) <= maple_oe;
		gpio_maple(11) <= not maple_oe;
		maple_sense <= gpio_maple(17); -- and sw(0);

		-- map maple bus to jamma inputs
		-- - same mappings as default mappings for MAMED (DCMAME)
		jamma.coin(1) 				<= mpj.lv(7);		-- MSB of right analogue trigger (0-255)
		jamma.p(1).start 			<= mpj.start;
		jamma.p(1).up 				<= mpj.d_up;
		jamma.p(1).down 			<= mpj.d_down;
		jamma.p(1).left	 			<= mpj.d_left;
		jamma.p(1).right 			<= mpj.d_right;
		jamma.p(1).button(1) 	<= mpj.a;
		jamma.p(1).button(2) 	<= mpj.x;
		jamma.p(1).button(3) 	<= mpj.b;
		jamma.p(1).button(4) 	<= mpj.y;
		jamma.p(1).button(5)	<= '1';

	end generate GEN_MAPLE;

	GEN_GAMECUBE : if DE2_JAMMA_IS_GAMECUBE generate
	
		GC_JOY: gamecube_joy
			generic map( MHZ => 50 )
  		port map
		  (
  			clk 				=> clock_50,
				reset 			=> reset,
				--oe 					=> gc_oe,
				d 					=> gpio_0(25),
				joystate 		=> gcj
			);

		-- map gamecube controller to jamma inputs
		jamma.coin(1) <= not gcj.l;
		jamma.p(1).start <= not gcj.start;
		jamma.p(1).up <= not gcj.d_up;
		jamma.p(1).down <= not gcj.d_down;
		jamma.p(1).left <= not gcj.d_left;
		jamma.p(1).right <= not gcj.d_right;
		jamma.p(1).button(1) <= not gcj.a;
		jamma.p(1).button(2) <= not gcj.b;
		jamma.p(1).button(3) <= not gcj.x;
		jamma.p(1).button(4) <= not gcj.y;
		jamma.p(1).button(5)	<= not gcj.z;

	end generate GEN_GAMECUBE;
	
	-- not currently wired to any inputs
	jamma.coin(2) <= '1';
	jamma.p(2).start <= '1';
	jamma.service <= '1';
	jamma.tilt <= '1';
	jamma.test <= '1';
		
	-- show JAMMA inputs on LED bank
	--ledr(17) <= not jamma.coin(1);
	--ledr(16) <= not jamma.coin(2);
	--ledr(15) <= not jamma.p(1).start;
	--ledr(14) <= not jamma.p(1).up;
	--ledr(13) <= not jamma.p(1).down;
	--ledr(12) <= not jamma.p(1).left;
	--ledr(11) <= not jamma.p(1).right;
	--ledr(10) <= not jamma.p(1).button(1);
	--ledr(9) <= not jamma.p(1).button(2);
	--ledr(8) <= not jamma.p(1).button(3);
	--ledr(7) <= not jamma.p(1).button(4);
	--ledr(6) <= not jamma.p(1).button(5);
		
  c24mhz_inst : ENTITY work.c24mhz
    PORT map
    (
      inclk0		    => clock_50,
      c0		        => clk_24M
    );

  minimig_de1_inst : entity work.minimig_de1
    generic map
    (
      HAS_I2C_AV_CONFIG  => true
    )
    port map
    (
      joya          => (others => '1'),
      joyb          => (others => '1'),
      sd_dat        => sd_dat,
      joy           => (others => '0'), -- not used
      clock_27(1)   => '0', -- not used
      clock_27(0)   => clock_27,
      clock_24(1)   => '0',
      clock_24(0)   => clk_24M,
      ext_clock     => ext_clock, -- not used,
      clock_50      => clock_50, -- not used
      key           => key, -- active low
      sw(9)        => sw(17), -- 15kHz
      sw(8 downto 0) => sw(8 downto 0),
      aud_adcdat    => aud_adcdat,
      uart_rxd      => uart_rxd,
      tdi           => tdi,
      tck           => tck,
      tcs           => tcs,
      dram_cke      => dram_cke,
      dram_dq       => dram_dq,
      dram_addr(11 downto 0) => dram_addr,
      dram_cs_n     => dram_cs_n,
      ledg          => ledg(7 downto 0),
      dram_ba_0     => dram_ba_0,
      dram_ba_1     => dram_ba_1,
      dram_we_n     => dram_we_n,
      dram_ldqm     => dram_ldqm,
      dram_ras_n    => dram_ras_n,
      dram_udqm     => dram_udqm,
      dram_cas_n    => dram_cas_n,
      fl_dq         => fl_dq,
      fl_ce_n       => fl_ce_n,
      fl_oe_n       => fl_oe_n,
      fl_rst_n      => fl_rst_n,
      fl_we_n       => fl_we_n,
      sram_dq       => sram_dq,
      fl_addr       => fl_addr,
      sram_addr     => sram_addr,
      sram_ub_n     => sram_ub_n,
      sram_lb_n     => sram_lb_n,
      sram_we_n     => sram_we_n,
      sram_ce_n     => sram_ce_n,
      ps2_mdat      => ps2_mdat,
      sram_oe_n     => sram_oe_n,
      ps2_mclk      => ps2_mclk,
      ps2_dat       => ps2_dat,
      ps2_clk       => ps2_clk,
      vga_hs        => vga_hs_s,
      tdo           => tdo,
      vga_vs        => vga_vs_s,
      vga_r         => vga_r(9 downto 6),
      vga_g         => vga_g(9 downto 6),
      vga_b         => vga_b(9 downto 6),
      sd_dat3       => sd_dat3,
      sd_clk        => sd_clk,
      sd_cmd        => sd_cmd,
      aud_adclrck   => aud_adclrck,
      uart_txd      => uart_txd,
      hex0          => hex0,
      hex1          => hex1,
      hex2          => hex2,
      hex3          => hex3,
      ledr          => ledr(9 downto 0),
      aud_xck       => aud_xck,
      aud_dacdat    => aud_dacdat,
      aud_daclrck   => aud_daclrck,
      aud_bclk      => aud_bclk,
      dram_clk      => dram_clk_s,
      i2c_sclk      => i2c_sclk,
      i2c_sdat      => i2c_sdat
    );
  vga_hs <= vga_hs_s;
  vga_vs <= vga_vs_s;
  dram_clk <= dram_clk_s;

  vga_r(5 downto 0) <= (others => '0');
  vga_g(5 downto 0) <= (others => '0');
  vga_b(5 downto 0) <= (others => '0');
  vga_clk <= dram_clk_s;
  vga_blank <= vga_hs_s and vga_vs_s;
  vga_sync <= '0';
  hex4 <= (others => '1');
  hex5 <= (others => '1');
  hex6 <= (others => '1');
  hex7 <= (others => '1');
  ledr(17 downto 16) <= (others => '0');
  ledr(15 downto 10) <= (others => '0');

end SYN;

