library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

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
    sram_i          : in from_SRAM_t;
    sram_o          : out to_SRAM_t;

    -- VGA video
		vga_clk					: out std_logic;
    red             : out std_logic_vector(9 downto 0);
    green           : out std_logic_vector(9 downto 0);
    blue            : out std_logic_vector(9 downto 0);
		lcm_data				:	out std_logic_vector(9 downto 0);
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

	signal I_RESET_L       : std_logic;
	--signal Clk          	 : std_logic;
	--signal Clk_x2          : std_logic;
	signal Rst_n_s         : std_logic;

	signal DIP_s           : std_logic_vector(8 downto 1);
	signal RWE_n           : std_logic;
	signal Video           : std_logic;
	signal VideoRGB        : std_logic_vector(2 downto 0);
	signal VideoRGB_X2     : std_logic_vector(7 downto 0);
	signal HSync_X1        : std_logic;
	signal VSync_X1        : std_logic;
	signal HSync_X2        : std_logic;
	signal VSync_X2        : std_logic;

	signal AD              : std_logic_vector(15 downto 0);
	signal RAB             : std_logic_vector(12 downto 0);
	signal RDB             : std_logic_vector(7 downto 0);
	signal RWD             : std_logic_vector(7 downto 0);
	signal IB              : std_logic_vector(7 downto 0);
	signal SoundCtrl3      : std_logic_vector(5 downto 0);
	signal SoundCtrl5      : std_logic_vector(5 downto 0);

	signal Buttons         : std_logic_vector(5 downto 0);
	signal Buttons_n       : std_logic_vector(5 downto 1);

	signal Tick1us         : std_logic;

	signal PS2_Sample      : std_logic;
	signal PS2_Data_s      : std_logic;
	signal ScanCode        : std_logic_vector(7 downto 0);
	signal Press           : std_logic;
	signal Release         : std_logic;
	signal Reset_s         : std_logic;

	signal rom_data_0      : std_logic_vector(7 downto 0);
	signal rom_data_1      : std_logic_vector(7 downto 0);
	signal rom_data_2      : std_logic_vector(7 downto 0);
	signal rom_data_3      : std_logic_vector(7 downto 0);
	signal ram_we          : std_logic;
	--
	signal HCnt            : std_logic_vector(11 downto 0);
	signal VCnt            : std_logic_vector(11 downto 0);
	signal HSync_t1        : std_logic;
	signal Overlay_G1      : boolean;
	signal Overlay_G2      : boolean;
	signal Overlay_R1      : boolean;
	signal Overlay_G1_VCnt : boolean;
	--
	signal Audio           : std_logic_vector(7 downto 0);
	signal AudioPWM        : std_logic;

	-- for PACE compatibility
	alias I_RESET					: std_logic is reset;
	alias Clk_X1					: std_logic is clk(0);	-- 10MHz
	alias Clk_X2					: std_logic is clk(1);	-- 20MHz
	alias I_PS2_CLK				: std_logic is ps2clk;
	alias I_PS2_DATA			: std_logic is ps2data;

	signal O_VIDEO_R			: std_logic;
	signal O_VIDEO_G			: std_logic;
	signal O_VIDEO_B			: std_logic;
	alias O_HSYNC					: std_logic is hsync;
	alias O_VSYNC					: std_logic is vsync;

	signal O_AUDIO_L			: std_logic;
	signal O_AUDIO_R			: std_logic;
				
begin

	-- declare a block only so we can muck with the namespace
	
	BLOCK_MAIN : block
	
		-- and alias back to the original names
		alias Clk 		: std_logic is Clk_X1;
		alias DIP			: std_logic_vector(DIP_s'range) is DIP_s;
		alias Reset		: std_logic is Reset_s;
		alias HSync		: std_logic is HSync_X1;
		alias VSync		: std_logic is VSync_X1;
		
	begin
	
  --
  I_RESET_L <= not I_RESET;
  --

	Buttons_n <= not Buttons(5 downto 1);
	DIP <= "00000000";

	core : entity work.invaders
		port map(
			Rst_n      => I_RESET_L,
			Clk        => Clk,
			Coin       => Buttons(0),
			Sel1Player => Buttons_n(1),
			Sel2Player => Buttons_n(2),
			Fire       => Buttons_n(3),
			MoveLeft   => Buttons_n(4),
			MoveRight  => Buttons_n(5),
			DIP        => DIP,
			RDB        => RDB,
			IB         => IB,
			RWD        => RWD,
			RAB        => RAB,
			AD         => AD,
			SoundCtrl3 => SoundCtrl3,
			SoundCtrl5 => SoundCtrl5,
			Rst_n_s    => Rst_n_s,
			RWE_n      => RWE_n,
			Video      => Video,
			HSync      => HSync,
			VSync      => VSync
			);
	--
	-- ROM
	--
	u_rom_h : entity work.INVADERS_ROM_H
	  port map (
		CLK         => Clk,
		ENA         => '1',
		ADDR        => AD(10 downto 0),
		DATA        => rom_data_0
		);
	--
	u_rom_g : entity work.INVADERS_ROM_G
	  port map (
		CLK         => Clk,
		ENA         => '1',
		ADDR        => AD(10 downto 0),
		DATA        => rom_data_1
		);
	--
	u_rom_f : entity work.INVADERS_ROM_F
	  port map (
		CLK         => Clk,
		ENA         => '1',
		ADDR        => AD(10 downto 0),
		DATA        => rom_data_2
		);
	--
	u_rom_e : entity work.INVADERS_ROM_E
	  port map (
		CLK         => Clk,
		ENA         => '1',
		ADDR        => AD(10 downto 0),
		DATA        => rom_data_3
		);
	--
	p_rom_data : process(AD, rom_data_0, rom_data_1, rom_data_2, rom_data_3)
	begin
	  IB <= (others => '0');
	  case AD(12 downto 11) is
		when "00" => IB <= rom_data_0;
		when "01" => IB <= rom_data_1;
		when "10" => IB <= rom_data_2;
		when "11" => IB <= rom_data_3;
		when others => null;
	  end case;
	end process;
	
	--
	-- SRAM
	--
	--ram_we <= not RWE_n;
	--rams : for i in 0 to 3 generate
	--  u_ram : component RAMB16_S2
	--  port map (
	--	do   => RDB((i*2)+1 downto (i*2)),
	--	addr => RAB,
	--	clk  => Clk,
	--	di   => RWD((i*2)+1 downto (i*2)),
	--	en   => '1',
	--	ssr  => '0',
	--	we   => ram_we
	--	);
	--end generate;

	process (Clk)
	begin
		if rising_edge(Clk) then
			sram_o.a <= EXT(RAB, sram_o.a'length);
			sram_o.cs <= '1';
			sram_o.oe <= RWE_n;
      sram_o.be <= EXT("1", sram_o.be'length);
			sram_o.we <= not RWE_n;
		end if;
	end process;

	sram_o.d <= EXT(RWD, sram_o.d'length) when RWE_n = '0' else (others => 'Z');
	RDB <= sram_i.d(RDB'range);
		
	--
	-- Glue
	--
	process (Rst_n_s, Clk)
		variable cnt : unsigned(3 downto 0);
	begin
		if Rst_n_s = '0' then
			cnt := "0000";
			Tick1us <= '0';
		elsif Clk'event and Clk = '1' then
			Tick1us <= '0';
			if cnt = 9 then
				Tick1us <= '1';
				cnt := "0000";
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
	--
	-- Keyboard decoder
	--
	kbd : entity work.ps2kbd
		port map(
			Rst_n => Rst_n_s,
			Clk => Clk,
			Tick1us => Tick1us,
			PS2_Clk => I_PS2_CLK,
			PS2_Data => I_PS2_DATA,
			Press => Press,
			Release => Release,
			Reset => Reset,
			ScanCode => ScanCode);

	process (Clk, Rst_n_s)
	begin
		if Rst_n_s = '0' then
			Buttons <= (others => '0');
		elsif Clk'event and Clk = '1' then
			if (Press or Release) = '1' then
				if ScanCode = x"21" then        -- c
					Buttons(0) <= Press;
				end if;
				if ScanCode = x"16" or ScanCode = x"69" then    -- 1
					Buttons(1) <= Press;
				end if;
				if ScanCode = x"1e" or ScanCode = x"72" then    -- 2
					Buttons(2) <= Press;
				end if;
				if ScanCode = x"29" then        -- Space
					Buttons(3) <= Press;
				end if;
				if ScanCode = x"6b" then        -- Left
					Buttons(4) <= Press;
				end if;
				if ScanCode = x"74" then        -- Right
					Buttons(5) <= Press;
				end if;
			end if;
			if Reset = '1' then
				Buttons <= (others => '0');
			end if;
		end if;
	end process;
  --
  -- Video Output
  --
  p_overlay : process(Rst_n_s, Clk)
	variable HStart : boolean;
  begin
	if Rst_n_s = '0' then
	  HCnt <= (others => '0');
	  VCnt <= (others => '0');
	  HSync_t1 <= '0';
	  Overlay_G1_VCnt <= false;
	  Overlay_G1 <= false;
	  Overlay_G2 <= false;
	  Overlay_R1 <= false;
	elsif Clk'event and Clk = '1' then
	  HSync_t1 <= HSync;
	  HStart := (HSync_t1 = '0') and (HSync = '1');-- rising

	  if HStart then
		HCnt <= (others => '0');
	  else
		HCnt <= HCnt + "1";
	  end if;

	  if (VSync = '0') then
		VCnt <= (others => '0');
	  elsif HStart then
		VCnt <= VCnt + "1";
	  end if;

	  if HStart then
		if (Vcnt = x"1F") then
		  Overlay_G1_VCnt <= true;
		elsif (Vcnt = x"95") then
		  Overlay_G1_VCnt <= false;
		end if;
	  end if;

	  if (HCnt = x"027") and Overlay_G1_VCnt then
		Overlay_G1 <= true;
	  elsif (HCnt = x"046") then
		Overlay_G1 <= false;
	  end if;

	  if (HCnt = x"046") then
		Overlay_G2 <= true;
	  elsif (HCnt = x"0B6") then
		Overlay_G2 <= false;
	  end if;

	  if (HCnt = x"1A6") then
		Overlay_R1 <= true;
	  elsif (HCnt = x"1E6") then
		Overlay_R1 <= false;
	  end if;

	end if;
  end process;

  p_video_out_comb : process(Video, Overlay_G1, Overlay_G2, Overlay_R1)
  begin
	if (Video = '0') then
	  VideoRGB  <= "000";
	else
	  if Overlay_G1 or Overlay_G2 then
		VideoRGB  <= "010";
	  elsif Overlay_R1 then
		VideoRGB  <= "100";
	  else
		VideoRGB  <= "111";
	  end if;
	end if;
  end process;

  u_dblscan : entity work.DBLSCAN
	port map (
	  RGB_IN(7 downto 3) => "00000",
	  RGB_IN(2 downto 0) => VideoRGB,
	  HSYNC_IN           => HSync,
	  VSYNC_IN           => VSync,

	  RGB_OUT            => VideoRGB_X2,
	  HSYNC_OUT          => HSync_X2,
	  VSYNC_OUT          => VSync_X2,
	  --  NOTE CLOCKS MUST BE PHASE LOCKED !!
	  CLK                => Clk,
	  CLK_X2             => Clk_x2
	);

  O_VIDEO_R <= VideoRGB_X2(2);
  O_VIDEO_G <= VideoRGB_X2(1);
  O_VIDEO_B <= VideoRGB_X2(0);
  O_HSYNC   <= not HSync_X2;
  O_VSYNC   <= not VSync_X2;
  --
  -- Audio
  --
  u_audio : entity work.invaders_audio
	port map (
	  Clk => Clk,
	  S1  => SoundCtrl3,
	  S2  => SoundCtrl5,
	  Aud => Audio
	  );

  u_dac : entity work.dac
	generic map(
	  msbi_g => 7
	)
	port  map(
	  clk_i   => Clk,
	  res_n_i => Rst_n_s,
	  dac_i   => Audio,
	  dac_o   => AudioPWM
	);

  O_AUDIO_L <= AudioPWM;
  O_AUDIO_R <= AudioPWM;

	end block BLOCK_MAIN;
	
	-- hook up the video to the output
	GEN_VIDEO : for i in 9 downto 0 generate
		red(i) <= O_VIDEO_R;
		green(i) <= O_VIDEO_G;
		blue(i) <= O_VIDEO_B;
	end generate GEN_VIDEO;
	
  -- not used
	
	vga_clk <= clk(1);	-- fudge

  spi_clk <= 'Z';
  spi_dout <= 'Z';
  spi_mode <= 'Z';
  spi_sel <= 'Z';
  
	leds <= (others => 'Z');

end SYN;

