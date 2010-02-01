Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.sdram_pkg.all;
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
    
    -- custom i/o
    project_i       : in from_PROJECT_IO_t;
    project_o       : out to_PROJECT_IO_t;
    platform_i      : in from_PLATFORM_IO_t;
    platform_o      : out to_PLATFORM_IO_t;
    target_i        : in from_TARGET_IO_t;
    target_o        : out to_TARGET_IO_t
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
			-- external ROM signals
			ROM_A_10_0    : out std_logic_vector(10 downto 0);
			ROM_DATA_I    : in std_logic_vector(7 downto 0);
      ENA_F8        : out std_logic;
      ENA_F0        : out std_logic;
      ENA_E8        : out std_logic;
      ENA_E0        : out std_logic;
      ENA_D8        : out std_logic;
      ENA_D0        : out std_logic;
      ENA_C8        : out std_logic;
      ENA_C0        : out std_logic;
      ENA_B8        : out std_logic;
      ENA_B0        : out std_logic;
      ENA_A8        : out std_logic;
      ENA_A0        : out std_logic;
      ENA_98        : out std_logic;
      ENA_90        : out std_logic;
      ENA_88        : out std_logic;
      ENA_80        : out std_logic;
      ENA_DSKD8     : out std_logic;
      ENA_DSKD0     : out std_logic;
      ENA_DSKC8     : out std_logic;
      ENA_DSKC0     : out std_logic;
      ENA_RS232C0   : out std_logic;
      ENA_RS232C8   : out std_logic;
      ENA_C0_S2     : out std_logic;
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

  signal ena_f8       : std_logic;
  signal ena_f0       : std_logic;
  signal ena_e8       : std_logic;
  signal ena_e0       : std_logic;
  signal ena_d8       : std_logic;
  signal ena_d0       : std_logic;
  signal ena_c8       : std_logic;
  signal ena_c0       : std_logic;
  signal ena_b8       : std_logic;
  signal ena_b0       : std_logic;
  signal ena_a8       : std_logic;
  signal ena_a0       : std_logic;
  signal ena_98       : std_logic;
  signal ena_90       : std_logic;
  signal ena_88       : std_logic;
  signal ena_80       : std_logic;
  signal ena_dskd8    : std_logic;
  signal ena_dskd0    : std_logic;
  signal ena_dskc8    : std_logic;
  signal ena_dskc0    : std_logic;
  signal ena_rs232c0  : std_logic;
  signal ena_rs232c8  : std_logic;
  signal ena_c0_s2    : std_logic;

  signal digit_n      : std_logic_vector(3 downto 0);
  
  signal ps2_kclk     : std_logic;
  signal ps2_kdat     : std_logic;
  signal video_o_s    : to_VIDEO_t;
  signal osd_ctrl_i   : std_logic_vector(15 downto 0);
  signal osd_ctrl_o   : std_logic_vector(15 downto 0);
  alias OSD_ENABLE    : std_logic is osd_ctrl_o(osd_ctrl_o'left);
  alias OSD_BUTTON    : std_logic_vector(3 downto 0) is osd_ctrl_o(11 downto 8);
  alias OSD_SWITCH    : std_logic_vector(7 downto 0) is osd_ctrl_o(7 downto 0);
  
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
	--GEN_SRAM_2 : if false generate

    -- hook up Burched SRAM module
    --GEN_D: for i in 0 to 7 generate
      --ram1_di(8+i) <= gp_i(35-i);
      --ram1_di(i) <= gp_i(35-i);
      --gp_o.d(35-i) <= ram1_do(i);
      --gp_o.d(27-i) <= 'Z';
    --end generate;
    --GEN_A: for i in 0 to 16 generate
      --gp_o.d(17-i) <= ram_address(i);
    --end generate;
    --gp_o.d(0) <= ram1_cs_n;                   -- CEAn
    --gp_o.d(18) <= '1';                        -- upper byte WEn
    --gp_o.d(19) <= ram_rw_n or ram1_be_n(0);   -- lower byte WEn

		--sram_o.a <= std_logic_vector(resize(unsigned(ram_address), sram_o.a'length));
		--sram_o.d <= ram1_do & ram0_do;
		--ram0_di <= sram_i.d(15 downto 0);
		--sram_o.be <= "00" & not ram0_be_n;
		--sram_o.cs <= not ram0_cs_n;
		--sram_o.oe <= not ram_oe_n;
		--sram_o.we <= not ram_rw_n;
	
	--end generate GEN_SRAM_2;
	
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

  GEN_FLASH_ADDRESS : if COCO3_ROMS_IN_FLASH generate
    flash_o.cs <= '1';
    flash_o.oe <= '1';
    flash_o.we <= '0';
    flash_o.a(flash_o.a'left downto 16) <= (others => '0');
    flash_o.a(15 downto 11) <=  
      "00000" when ena_f8 = '1' else
      "00001" when ena_f0 = '1' else
      "00010" when ena_e8 = '1' else
      "00011" when ena_e0 = '1' else
      "00100" when ena_d8 = '1' else
      "00101" when ena_d0 = '1' else
      "00110" when ena_c8 = '1' else
      "00111" when ena_c0 = '1' else
      "01000" when ena_b8 = '1' else
      "01001" when ena_b0 = '1' else
      "01010" when ena_a8 = '1' else
      "01011" when ena_a0 = '1' else
      "01100" when ena_98 = '1' else
      "01101" when ena_90 = '1' else
      "01110" when ena_a8 = '1' else
      "01111" when ena_a0 = '1' else
      "10000" when ena_dskd8 = '1' else
      "10001" when ena_dskd0 = '1' else
      "10010" when ena_dskc8 = '1' else
      "10011" when ena_dskc0 = '1' else
      "10100" when ena_rs232c0 = '1' else
      "10101" when ena_rs232c8 = '1' else
      "10110" when ena_c0_s2 = '1' else
      (others => '0');
  end generate GEN_FLASH_ADDRESS;
  
	BLK_COCO3 : block
    signal coco_reset     : std_logic := '0';
    signal coco_switches  : std_logic_vector(7 downto 0);
    signal joystk_x       : std_logic_vector(7 downto 0);
    signal joystk_y       : std_logic_vector(7 downto 0);
	begin

    -- can use F3 to reset coco
    coco_reset <= reset_i or OSD_BUTTON(3);  -- F3
    
    GEN_DE2_SWITCHES : if PACE_TARGET = PACE_TARGET_DE1 or PACE_TARGET = PACE_TARGET_DE2 generate
      coco_switches <= switches_i(coco_switches'range);
    end generate GEN_DE2_SWITCHES;
    
    GEN_DEFAULT_SWITCHES : if PACE_TARGET = PACE_TARGET_P2A generate
      -- Normal speed, select MPI slot 4 (disk controller)
      coco_switches <= "00001100";
    end generate GEN_DEFAULT_SWITCHES;

    -- extend to extremeties and invert Y axis
    
    joystk_x <= X"00" when inputs_i.analogue(1)(9 downto 8) = "00" else 
                X"FF" when inputs_i.analogue(1)(9 downto 8) = "11" else
                inputs_i.analogue(1)(9 downto 2);
    joystk_y <= not X"00" when inputs_i.analogue(2)(9 downto 8) = "00" else 
                not X"FF" when inputs_i.analogue(2)(9 downto 8) = "11" else
                not inputs_i.analogue(2)(9 downto 2);
    
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
        
        -- ROM
        ROM_A_10_0    => flash_o.a(10 downto 0),
        ROM_DATA_I    => flash_i.d(7 downto 0),
        ENA_F8        => ena_f8,
        ENA_F0        => ena_f0,
        ENA_E8        => ena_e8,
        ENA_E0        => ena_e0,
        ENA_D8        => ena_d8,
        ENA_D0        => ena_d0,
        ENA_C8        => ena_c8,
        ENA_C0        => ena_c0,
        ENA_B8        => ena_b8,
        ENA_B0        => ena_b0,
        ENA_A8        => ena_a8,
        ENA_A0        => ena_a0,
        ENA_98        => ena_98,
        ENA_90        => ena_90,
        ENA_88        => ena_88,
        ENA_80        => ena_80,
        ENA_DSKD8     => ena_dskd8,
        ENA_DSKD0     => ena_dskd0,
        ENA_DSKC8     => ena_dskc8,
        ENA_DSKC0     => ena_dskc0,
        ENA_RS232C0   => ena_rs232c0,
        ENA_RS232C8   => ena_rs232c8,
        ENA_C0_S2     => ena_c0_s2,

        -- VGA
        RED1					=> video_o_s.rgb.r(9),
        GREEN1				=> video_o_s.rgb.g(9),
        BLUE1					=> video_o_s.rgb.b(9),
        RED0					=> video_o_s.rgb.r(8),
        GREEN0				=> video_o_s.rgb.g(8),
        BLUE0					=> video_o_s.rgb.b(8),
        H_SYNC				=> video_o_s.hsync,
        V_SYNC				=> video_o_s.vsync,
        
        -- PS/2
        ps2_clk				=> ps2_kclk,
        ps2_data			=> ps2_kdat,
        
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
        LED						=> osd_ctrl_i(7 downto 0),
        
        -- CoCo Perpherial
        SPEAKER				=> open,
        --PADDLE				=> (others => '0'),
        --PADDLE_RST    => open,
        --PADDLE1       => inputs_i.analogue(3)(9 downto 4),
        --PADDLE2       => inputs_i.analogue(4)(9 downto 4),
        PADDLE1       => joystk_x(7 downto 2),
        PADDLE2       => joystk_y(7 downto 2),
        PADDLE3       => joystk_x(7 downto 2),  -- Left X
        PADDLE4       => joystk_y(7 downto 2),  -- Left Y
        -- paddle switches are active low (like jamma)
        P_SWITCH(3)		=> inputs_i.jamma_n.p(1).button(3),   -- Right 1
        P_SWITCH(2)		=> inputs_i.jamma_n.p(1).button(1),   -- Left 2
        P_SWITCH(1)		=> inputs_i.jamma_n.p(1).button(2),   -- Left 1
        P_SWITCH(0)		=> inputs_i.jamma_n.p(1).button(4),   -- Right 2
        
        -- Extra Buttons and Switches
        --SWITCH				=> (others => '0'), -- fast=1.78MHz
        SWITCH				=> OSD_SWITCH,
        BUTTON(3)			=> coco_reset,
        --BUTTON(2 downto 0) => "000"
        BUTTON(2 downto 0) => OSD_BUTTON(2 downto 0)
      );

  end block BLK_COCO3;
  
  -- 7-segment display
  process (clk_50M, reset_i)
  begin
    if reset_i = '1' then
      null;
    elsif rising_edge(clk_50M) then
      if digit_n = "1101" then
        --gp_o.d(39 downto 36) <= X"0";
      elsif digit_n = "1011" then
        --gp_o.d(43 downto 40) <= X"C";
      elsif digit_n = "0111" then
        --gp_o.d(47 downto 44) <= X"0";
      else
        --gp_o.d(51 downto 48) <= X"C";
      end if;
    end if;
  end process;

  GEN_OSD : if PACE_HAS_OSD generate
    BLK_OSD : block
    
      component OSD is
        generic
        (
          CLK_MHz         : integer := 50;
          OSD_X           : natural := 320;
          OSD_Y           : natural := 320;
          OSD_WIDTH       : natural := 512;
          OSD_HEIGHT      : natural := 128
        );
        port
        (
          clk             : in std_logic;
          clk_ena         : in std_logic;
          reset           : in std_logic;

          -- PS/2 key pass-thru
          ps2_kclk_i      : in std_logic;
          ps2_kdat_i      : in std_logic;
          ps2_kclk_o      : out std_logic;
          ps2_kdat_o      : out std_logic;

          -- video in
          vid_clk         : in std_logic;
          vid_hsync       : in std_logic;
          vid_vsync       : in std_logic;
          vid_r_i         : in std_logic_vector(9 downto 0);
          vid_g_i         : in std_logic_vector(9 downto 0);
          vid_b_i         : in std_logic_vector(9 downto 0);

          -- OSD control input/output
          osd_ctrl_i      : in std_logic_vector(15 downto 0);
          osd_ctrl_o      : out std_logic_vector(15 downto 0);
          
          -- osd character rom
          chr_a           : out std_logic_vector(10 downto 0);
          chr_d           : in std_logic_vector(7 downto 0);
          
          -- video out
          vid_r_o         : out std_logic_vector(9 downto 0);
          vid_g_o         : out std_logic_vector(9 downto 0);
          vid_b_o         : out std_logic_vector(9 downto 0);
          
          -- SPI ports
          eurospi_clk     : in std_logic;
          eurospi_miso    : out std_logic;
          eurospi_mosi    : in std_logic;
          eurospi_ss      : in std_logic
        );
      end component OSD;
      
      signal chr_a    : std_logic_vector(10 downto 0) := (others => '0');
      signal chr_d    : std_logic_vector(7 downto 0) := (others => '0');
      
    begin
    
      osd_ctrl_i(15 downto 8) <= (others => '0');
      
      osd_inst : OSD
        port map
        (
          clk             => clk_50M,
          clk_ena         => '1',
          reset           => reset_i,

          ps2_kclk_i      => inputs_i.ps2_kclk,
          ps2_kdat_i      => inputs_i.ps2_kdat,
          ps2_kclk_o      => ps2_kclk,
          ps2_kdat_o      => ps2_kdat,
          
          vid_clk         => video_o_s.clk,
          vid_hsync       => video_o_s.hsync,
          vid_vsync       => video_o_s.vsync,
          vid_r_i         => video_o_s.rgb.r,
          vid_g_i         => video_o_s.rgb.g,
          vid_b_i         => video_o_s.rgb.b,

          osd_ctrl_i      => osd_ctrl_i,
          osd_ctrl_o      => osd_ctrl_o,
          
          chr_a           => chr_a,
          chr_d           => chr_d,
          
          vid_r_o         => video_o.rgb.r,
          vid_g_o         => video_o.rgb.g,
          vid_b_o         => video_o.rgb.b,
          
          -- SPI ports
          eurospi_clk     => '0', --gp_i(P2A_EUROSPI_CLK),
          eurospi_miso    => open, --gp_o.d(P2A_EUROSPI_MISO),
          eurospi_mosi    => '0', --gp_i(P2A_EUROSPI_MOSI),
          eurospi_ss      => '0' --gp_i(P2A_EUROSPI_SS)
        );

        tilerom_inst : entity work.sprom
          generic map
          (
            init_file		=> "../../../../../src/platform/coco3-becker/roms/coco3gen.hex",
            numwords_a	=> 2048,
            widthad_a		=> 11
          )
          port map
          (
            clock			  => video_o_s.clk,
            address		  => chr_a,
            q           => chr_d
          );

    end block BLK_OSD;
  end generate GEN_OSD;

  GEN_NO_OSD : if not PACE_HAS_OSD generate
    osd_ctrl_o <= (others => '0');
    ps2_kclk <= inputs_i.ps2_kclk;
    ps2_kdat <= inputs_i.ps2_kdat;
    video_o.rgb.r <= video_o_s.rgb.r;
    video_o.rgb.g <= video_o_s.rgb.g;
    video_o.rgb.b <= video_o_s.rgb.b;
  end generate GEN_NO_OSD;
  
  -- interboard spi
  -- - always the slave
  --gp_o.oe(P2A_EUROSPI_CLK) <= '0';
  --gp_o.oe(P2A_EUROSPI_MISO) <= '1';
  --gp_o.oe(P2A_EUROSPI_MOSI) <= '0';
  --gp_o.oe(P2A_EUROSPI_SS) <= '0';
  
	-- unused
	video_o_s.clk <= clk_50M;
	video_o_s.rgb.r(7 downto 0) <= (others => '0');
	video_o_s.rgb.g(7 downto 0) <= (others => '0');
	video_o_s.rgb.b(7 downto 0) <= (others => '0');

	video_o.clk <= video_o_s.clk;
	video_o.hsync <= video_o_s.hsync;
	video_o.vsync <= video_o_s.vsync;
	video_o.hblank <= video_o_s.hblank;
	video_o.vblank <= video_o_s.vblank;

  spi_o <= NULL_TO_SPI;
  
end SYN;

