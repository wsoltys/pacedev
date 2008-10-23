Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk             : in std_logic_vector(0 to 3);
    test_button     : in std_logic;
    reset           : in std_logic;

    -- game I/O
    ps2clk          : inout std_logic;
    ps2data         : inout std_logic;
    dip             : in std_logic_vector(7 downto 0);
		jamma						: in JAMMAInputsType;

    -- external RAM
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
		hblank					: out std_logic;
		vblank					: out std_logic;
    hsync           : out std_logic;
    vsync           : out std_logic;

    -- composite video
    BW_CVBS         : out std_logic_vector(1 downto 0);
    GS_CVBS         : out std_logic_vector(7 downto 0);

    -- sound
    snd_clk         : out std_logic;
    snd_data_l      : out std_logic_vector(15 downto 0);
    snd_data_r      : out std_logic_vector(15 downto 0);

    -- SPI (flash)
    spi_clk         : out std_logic;
    spi_mode        : out std_logic;
    spi_sel         : out std_logic;
    spi_din         : in std_logic;
    spi_dout        : out std_logic;

    -- serial
    ser_tx          : out std_logic;
    ser_rx          : in std_logic;

    -- debug
    leds            : out std_logic_vector(7 downto 0)
  );

end PACE;

architecture SYN of PACE is

	component coco3fpga is
		port
		(
			CLK50MHZ			: in std_logic;
			
			-- RAM, ROM, and Peripherials
			RAM_DATA0_I		: in std_logic_vector(15 downto 0);			-- 16 bit data bus from RAM 0
			RAM_DATA0_O		: out std_logic_vector(15 downto 0);		-- 16 bit data bus to RAM 0
			RAM_DATA1_I	  : in std_logic_vector(15 downto 0);	    -- 16 bit data bus from RAM 1
			RAM_DATA1_O		: out std_logic_vector(15 downto 0);	  -- 16 bit data bus to RAM 1
			RAM_ADDRESS		: out std_logic_vector(17 downto 0);		-- Common address
			RAM_RW_N			: out std_logic;												-- Common RW
			RAM0_CS_N			: out std_logic;												-- Chip Select for RAM 0
			RAM1_CS_N			: out std_logic;												-- Chip Select for RAM 1
			RAM0_BE0_N		: out std_logic;												-- Byte Enable for RAM 0
			RAM0_BE1_N		: out std_logic;												-- Byte Enable for RAM 0
			RAM1_BE0_N		: out std_logic;												-- Byte Enable for RAM 1
			RAM1_BE1_N		: out std_logic;												-- Byte Enable for RAM 1
			RAM_OE_N			: out std_logic;
			
			-- VGA
			RED1					: out std_logic;
			GREEN1				: out std_logic;
			BLUE1					: out std_logic;
			RED0					: out std_logic;
			GREEN0				: out std_logic;
			BLUE0					: out std_logic;
			H_SYNC				: out std_logic;
			V_SYNC				: out std_logic;
			
			-- PS/2
			ps2_clk				: in std_logic;
			ps2_data			: in std_logic;
			
			--Serial Ports
			TXD1					: out std_logic;
			RXD1					: in std_logic;
			TXD2					: out std_logic;
			RXD2					: in std_logic;
			
			-- Display
			DIGIT_N				: out std_logic_vector(3 downto 0);
			SEGMENT_N			: out std_logic_vector(7 downto 0);
			
			-- LEDs
			LED						: out std_logic_vector(7 downto 0);
			
			-- CoCo Perpherial
			SPEAKER				: out std_logic;
			PADDLE				: in std_logic_vector(7 downto 0);
			P_SWITCH			: in std_logic_vector(3 downto 0);
			
			-- Extra Buttons and Switches
			SWITCH				: in std_logic_vector(7 downto 0);
			BUTTON				: in std_logic_vector(3 downto 0);
			PH_2					: out std_logic
		);
	end component;

	alias clk_50M 		  : std_logic is clk(0);
	
  signal ram_address  : std_logic_vector(17 downto 0);
	signal ram0_di		  : std_logic_vector(15 downto 0);
	signal ram0_do		  : std_logic_vector(15 downto 0);
	signal ram_rw_n		  : std_logic;
	signal ram0_cs_n	  : std_logic;
	signal ram1_cs_n	  : std_logic;
	signal ram0_be_n	  : std_logic_vector(1 downto 0);
	signal ram1_be_n	  : std_logic_vector(1 downto 0);
	signal ram_oe_n		  : std_logic;

begin

	--GEN_RMW_SRAM : if PACE_TARGET = PACE_TARGET_P2 generate
	GEN_RMW_SRAM : if false generate
	
		BLK_SRAM : block

			signal rmw_a    : std_logic_vector(ram_address'range);
	    signal rmw_oe   : std_logic;
	    signal rmw_we   : std_logic;

			constant DELAY	: time := 2 ns;

			type state_t 		is (IDLE, READ, WRITE1, WRITE2);
			signal state		: state_t;
			
		begin

			process (clk_50M, reset)
				variable rmw_di			: std_logic_vector(15 downto 0);
				variable rmw_do			: std_logic_vector(15 downto 0);
				variable rmw_be			: std_logic_vector(ram0_be_n'range);
			begin
				if reset = '1' then
					state <= IDLE after DELAY;
				elsif rising_edge(clk_50M) then
					case state is
						when IDLE =>
							if ram0_cs_n = '0' and ram_rw_n = '0' then
								-- start read-write-modify cycle
								rmw_a <= ram_address;
								rmw_do := ram0_do;
								rmw_be := not ram0_be_n;
								rmw_oe <= '1' after DELAY;
								rmw_we <= '0' after DELAY;
								state <= READ after DELAY;
							end if;
							
						when READ =>
							-- wait 20ns
							state <= WRITE1 after DELAY;

						when WRITE1 =>
							-- OR-in the value and write back
							rmw_di := sram_i.d(15 downto 0);
							if rmw_be(1) = '1' then
								sram_o.d(15 downto 8) <= rmw_do(15 downto 8) after DELAY;
							else
								sram_o.d(15 downto 8) <= rmw_di(15 downto 8) after DELAY;
							end if;
							if rmw_be(0) = '1' then
								sram_o.d(7 downto 0) <= rmw_do(7 downto 0) after DELAY;
							else
								sram_o.d(7 downto 0) <= rmw_di(7 downto 0) after DELAY;
							end if;
							rmw_oe <= '0' after DELAY;
							rmw_we <= '1' after DELAY;
							state <= WRITE2 after DELAY;
							
						when WRITE2 =>
							state <= IDLE after DELAY;
							
						when others =>
							state <= IDLE after DELAY;
					end case;
				end if;
			end process;

			sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length)) when state = IDLE else
									std_logic_vector(resize(unsigned(rmw_a), sram_o.a'length));
			sram_o.d(31 downto 16) <= (others => '0');
			ram0_di <= sram_i.d(ram0_di'range);
			sram_o.be <=  std_logic_vector(resize(unsigned("11"), sram_o.be'length));
			sram_o.cs <= not ram0_cs_n when state = IDLE else '1';
			sram_o.oe <= not ram_oe_n when state = IDLE else rmw_oe;
			sram_o.we <= '0' when state = IDLE else rmw_we;
			
		end block BLK_SRAM;

	end generate GEN_RMW_SRAM;

	GEN_EXPERIMENTAL : if PACE_TARGET = PACE_TARGET_P2 generate
	
		sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		sram_o.d <= std_logic_vector(resize(unsigned(ram0_do), sram_o.d'length));
		ram0_di <= sram_i.d(7 downto 0) & sram_i.d(7 downto 0);
		sram_o.be <= std_logic_vector(resize(unsigned(not ram0_be_n), sram_o.be'length));
		sram_o.cs <= not ram0_cs_n;
		sram_o.oe <= not ram_oe_n;
		sram_o.we <= not ram_rw_n;
	
	end generate GEN_EXPERIMENTAL;
		
	GEN_SRAM : if PACE_TARGET	= PACE_TARGET_DE2 generate

		sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		sram_o.d <= std_logic_vector(resize(unsigned(ram0_do), sram_o.d'length));
		ram0_di <= sram_i.d(ram0_di'range);
		sram_o.be <= std_logic_vector(resize(unsigned(not ram0_be_n), sram_o.be'length));
		sram_o.cs <= not ram0_cs_n;
		sram_o.oe <= not ram_oe_n;
		sram_o.we <= not ram_rw_n;
	
	end generate GEN_SRAM;
	
	coco_inst : coco3fpga
		port map
		(
			CLK50MHZ			=> clk_50M,
			
			-- RAM, ROM, and Peripherials
			RAM_DATA0_I		=> ram0_di,
			RAM_DATA0_O		=> ram0_do,
			RAM_DATA1_I	  => X"AA55",
      RAM_DATA1_O   => open,
			RAM_ADDRESS		=> ram_address,
			RAM_RW_N			=> ram_rw_n,
			RAM0_CS_N			=> ram0_cs_n,
			RAM1_CS_N			=> ram1_cs_n,
			RAM0_BE0_N		=> ram0_be_n(0),
			RAM0_BE1_N		=> ram0_be_n(1),
			RAM1_BE0_N		=> ram1_be_n(0),
			RAM1_BE1_N		=> ram1_be_n(1),
			RAM_OE_N			=> ram_oe_n,
			
			-- VGA
			RED1					=> red(9),
			GREEN1				=> green(9),
			BLUE1					=> blue(9),
			RED0					=> red(8),
			GREEN0				=> green(8),
			BLUE0					=> blue(8),
			H_SYNC				=> hsync,
			V_SYNC				=> vsync,
			
			-- PS/2
			ps2_clk				=> ps2clk,
			ps2_data			=> ps2data,
			
			--Serial Ports
			TXD1					=> ser_tx,
			RXD1					=> ser_rx,
			TXD2					=> open,
			RXD2					=> '0',
			
			-- Display
			DIGIT_N				=> open,
			SEGMENT_N			=> open,
			
			-- LEDs
			LED						=> leds,
			
			-- CoCo Perpherial
			SPEAKER				=> open,
			PADDLE				=> (others => '0'),
			P_SWITCH			=> (others => '0'),
			
			-- Extra Buttons and Switches
			SWITCH				=> (others => '0'), -- fast=1.78MHz
			BUTTON(3)			=> reset,
			BUTTON(2 downto 0) => "000",
			PH_2					=> open
		);

	vga_clk <= clk_50M;

	-- unused
	red(7 downto 0) <= (others => '0');
	green(7 downto 0) <= (others => '0');
	blue(7 downto 0) <= (others => '0');
	
  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';
  
end SYN;

