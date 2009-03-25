Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.sprite_pkg.all;
use work.platform_pkg.all;
use work.target_pkg.all;
use work.project_pkg.all;

entity PACE is
  port
  (
  	-- clocks and resets
    clk_i           : in std_logic_vector(0 to 3);
    reset_i         : in std_logic;

    -- misc I/O
    buttons_i       : in from_BUTTONS_t;
    switches_i      : in from_SWITCHES_t;
    leds_o          : out to_LEDS_t;

    -- controller inputs
    inputs_i        : in from_INPUTS_t;

    -- external ROM/RAM
    flash_i         : in from_FLASH_t;
    flash_o         : out to_flash_t;
    sram_i       		: in from_SRAM_t;
		sram_o					: out to_SRAM_t;
    sdram_i         : in from_SDRAM_t;
    sdram_o         : out to_SDRAM_t;

    -- video
    video_i         : in from_VIDEO_t;
    video_o         : out to_VIDEO_t;

    -- audio
    audio_i         : in from_AUDIO_t;
    audio_o         : out to_AUDIO_t;
    
    -- SPI (flash)
    spi_i           : in from_SPI_t;
    spi_o           : out to_SPI_t;

    -- serial
    ser_i           : in from_SERIAL_t;
    ser_o           : out to_SERIAL_t;
    
    -- general purpose I/O
    gp_i            : in from_GP_t;
    gp_o            : out to_GP_t
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
			RAM_ADDRESS		: out std_logic_vector(18 downto 0);		-- Common address
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
			TXD3					: out std_logic;
			RXD3					: in std_logic;
      RTS3          : out std_logic;
      CTS3          : in std_logic;
			
			-- Display
			DIGIT_N				: out std_logic_vector(3 downto 0);
			SEGMENT_N			: out std_logic_vector(7 downto 0);
			
			-- LEDs
			LED						: out std_logic_vector(7 downto 0);
			
			-- CoCo Perpherial
			SPEAKER				: out std_logic_vector(1 downto 0);
			--PADDLE				: in std_logic_vector(3 downto 0);
			--PADDLE_RST    : out std_logic_vector(3 downto 0);
			PADDLE1			  : in std_logic_vector(7 downto 2);
			PADDLE2			  : in std_logic_vector(7 downto 2);
			PADDLE3			  : in std_logic_vector(7 downto 2);
			PADDLE4			  : in std_logic_vector(7 downto 2);
			P_SWITCH			: in std_logic_vector(3 downto 0);
			
			-- Extra Buttons and Switches
			SWITCH				: in std_logic_vector(7 downto 0);
			BUTTON				: in std_logic_vector(3 downto 0)
		);
	end component;

	alias clk_50M 		  : std_logic is clk_i(0);
	
  signal ram_address  : std_logic_vector(18 downto 0);
	signal ram1_di		  : std_logic_vector(15 downto 0);
	signal ram1_do		  : std_logic_vector(15 downto 0);
	signal ram0_di		  : std_logic_vector(15 downto 0);
	signal ram0_do		  : std_logic_vector(15 downto 0);
	signal ram_rw_n		  : std_logic;
	signal ram0_cs_n	  : std_logic;
	signal ram1_cs_n	  : std_logic;
	signal ram0_be_n	  : std_logic_vector(1 downto 0);
	signal ram1_be_n	  : std_logic_vector(1 downto 0);
	signal ram_oe_n		  : std_logic;
  signal digit_n      : std_logic_vector(3 downto 0);
  
begin

	GEN_SRAM_16 : if  PACE_TARGET = PACE_TARGET_P2A or
                    PACE_TARGET = PACE_TARGET_DE1 or
                    PACE_TARGET = PACE_TARGET_DE2 generate

    -- this is for 32-bit wide memory
		--sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		--sram_o.d <= ram1_do & ram0_do;
		--ram1_di <= sram_i.d(31 downto 16);
		--ram0_di <= sram_i.d(15 downto 0);
		--sram_o.be <= ((ram1_cs_n & ram1_cs_n) nor ram1_be_n) & ((ram0_cs_n & ram0_cs_n) nor ram0_be_n);
		--sram_o.cs <= ram1_cs_n nand ram0_cs_n;
		--sram_o.oe <= not ram_oe_n;
		--sram_o.we <= not ram_rw_n;

    -- this is for 16-bit wide memory
		sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		sram_o.d(31 downto 16) <= (others => '0');
		sram_o.d(15 downto 0) <= ram1_do when ram1_cs_n = '0' else ram0_do;
		ram1_di <= sram_i.d(15 downto 0);
		ram0_di <= sram_i.d(15 downto 0);
		sram_o.be <= "00" & (ram1_be_n(1) nand ram0_be_n(1)) & (ram1_be_n(0) nand ram0_be_n(0));
		sram_o.cs <= ram1_cs_n nand ram0_cs_n;
		sram_o.oe <= not ram_oe_n;
		sram_o.we <= not ram_rw_n;
	
	end generate GEN_SRAM_16;
	
	--GEN_SRAM_2 : if PACE_TARGET = PACE_TARGET_DE1 generate
	GEN_SRAM_2 : if false generate

    -- hook up Burched SRAM module
    GEN_D: for i in 0 to 7 generate
      ram1_di(8+i) <= gp_i(35-i);
      ram1_di(i) <= gp_i(35-i);
      gp_o.d(35-i) <= ram1_do(i);
      gp_o.d(27-i) <= 'Z';
    end generate;
    GEN_A: for i in 0 to 16 generate
      gp_o.d(17-i) <= ram_address(i);
    end generate;
    gp_o.d(0) <= ram1_cs_n;                   -- CEAn
    gp_o.d(18) <= '1';                        -- upper byte WEn
    gp_o.d(19) <= ram_rw_n or ram1_be_n(0);   -- lower byte WEn

		sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		sram_o.d <= ram1_do & ram0_do;
		ram0_di <= sram_i.d(15 downto 0);
		sram_o.be <= "00" & not ram0_be_n;
		sram_o.cs <= not ram0_cs_n;
		sram_o.oe <= not ram_oe_n;
		sram_o.we <= not ram_rw_n;
	
	end generate GEN_SRAM_2;
	
	GEN_SRAM_COCO3PLUS : if PACE_TARGET = PACE_TARGET_COCO3PLUS generate

		sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		sram_o.d <= ram1_do & ram0_do;
		ram1_di <= sram_i.d(31 downto 16);
		ram0_di <= sram_i.d(15 downto 0);
		sram_o.be <= ((ram1_cs_n & ram1_cs_n) nor ram1_be_n) & ((ram0_cs_n & ram0_cs_n) nor ram0_be_n);
		sram_o.cs <= ram1_cs_n nand ram0_cs_n;
		sram_o.oe <= not ram_oe_n;
		sram_o.we <= not ram_rw_n;
	
	end generate GEN_SRAM_COCO3PLUS;
	
	BLK_COCO3 : block
    signal coco_switches : std_logic_vector(7 downto 0);
	begin
	
    GEN_DE2_SWITCHES : if PACE_TARGET = PACE_TARGET_DE2 generate
      coco_switches <= switches_i(coco_switches'range);
    end generate GEN_DE2_SWITCHES;
    
    GEN_DEFAULT_SWITCHES : if PACE_TARGET = PACE_TARGET_P2A generate
      -- Normal speed, select MPI slot 4 (disk controller)
      coco_switches <= "00001100";
    end generate GEN_DEFAULT_SWITCHES;
    
    coco_inst : coco3fpga
      port map
      (
        CLK50MHZ			=> clk_50M,
        
        -- RAM, ROM, and Peripherials
        RAM_DATA0_I		=> ram0_di,
        RAM_DATA0_O		=> ram0_do,
        RAM_DATA1_I	  => ram1_di,
        RAM_DATA1_O   => ram1_do,
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
        RED1					=> video_o.rgb.r(9),
        GREEN1				=> video_o.rgb.g(9),
        BLUE1					=> video_o.rgb.b(9),
        RED0					=> video_o.rgb.r(8),
        GREEN0				=> video_o.rgb.g(8),
        BLUE0					=> video_o.rgb.b(8),
        H_SYNC				=> video_o.hsync,
        V_SYNC				=> video_o.vsync,
        
        -- PS/2
        ps2_clk				=> inputs_i.ps2_kclk,
        ps2_data			=> inputs_i.ps2_kdat,
        
        --Serial Ports
        TXD1					=> ser_o.txd,
        RXD1					=> ser_i.rxd,
        TXD2					=> open,
        RXD2					=> '0',
        TXD3					=> open,
        RXD3					=> '0',
        RTS3          => open,
        CTS3          => '0',
        
        -- Display
        DIGIT_N				=> digit_n,
        SEGMENT_N			=> open,
        
        -- LEDs
        LED						=> leds_o(7 downto 0),
        
        -- CoCo Perpherial
        SPEAKER				=> open,
        --PADDLE				=> (others => '0'),
        --PADDLE_RST    => open,
        --PADDLE1       => inputs_i.analogue(3)(9 downto 4),
        --PADDLE2       => inputs_i.analogue(4)(9 downto 4),
        PADDLE1       => inputs_i.analogue(1)(9 downto 4),
        PADDLE2       => inputs_i.analogue(2)(9 downto 4),
        PADDLE3       => inputs_i.analogue(1)(9 downto 4),  -- Left X
        PADDLE4       => inputs_i.analogue(2)(9 downto 4),  -- Left Y
        -- paddle switches are active low (like jamma)
        P_SWITCH(3)		=> inputs_i.jamma_n.p(2).button(2),   -- Right 1
        P_SWITCH(2)		=> inputs_i.jamma_n.p(1).button(1),   -- Left 2
        P_SWITCH(1)		=> inputs_i.jamma_n.p(1).button(2),   -- Left 1
        P_SWITCH(0)		=> inputs_i.jamma_n.p(2).button(1),   -- Right 2
        
        -- Extra Buttons and Switches
        --SWITCH				=> (others => '0'), -- fast=1.78MHz
        SWITCH				=> coco_switches,
        BUTTON(3)			=> reset_i,
        --BUTTON(2 downto 0) => "000"
        BUTTON(2 downto 0) => buttons_i(3 downto 1)
      );

  end block BLK_COCO3;
  
  -- 7-segment display
  process (clk_50M, reset_i)
  begin
    if reset_i = '1' then
      null;
    elsif rising_edge(clk_50M) then
      if digit_n = "1101" then
        gp_o.d(39 downto 36) <= X"0";
      elsif digit_n = "1011" then
        gp_o.d(43 downto 40) <= X"C";
      elsif digit_n = "0111" then
        gp_o.d(47 downto 44) <= X"0";
      else
        gp_o.d(51 downto 48) <= X"C";
      end if;
    end if;
  end process;
  
	video_o.clk <= clk_50M;

	-- unused
	video_o.rgb.r(7 downto 0) <= (others => '0');
	video_o.rgb.g(7 downto 0) <= (others => '0');
	video_o.rgb.b(7 downto 0) <= (others => '0');

  spi_o <= NULL_TO_SPI;
  
end SYN;

