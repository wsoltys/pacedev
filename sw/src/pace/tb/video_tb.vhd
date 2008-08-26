library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dummy_mem is
	port (
		clk				: in std_logic;
    addr			: in std_logic_vector(15 downto 0);
    data			: out std_logic_vector(15 downto 0)
	);
end dummy_mem;

architecture SIM of dummy_mem is
begin
	process(clk)
	begin
    if rising_edge (clk) then
		  data <= addr(15 downto 0) after 2 ns;
    end if;
	end process;
end SIM;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dummy_mem2 is
	port (
		clk				: in std_logic;
    addr			: in std_logic_vector(15 downto 0);
    data			: out std_logic_vector(7 downto 0)
	);
end dummy_mem2;

architecture SIM of dummy_mem2 is
begin
	process(clk)
	begin
    if rising_edge(clk) then
  		--data <= addr(4) & addr(4) & addr(4) & addr(4) & addr(0) & addr(0) & addr(0) & addr(0) after 2 ns;
  		--data <= addr(0) & addr(0) & addr(0) & addr(0) & addr(4) & addr(4) & addr(4) & addr(4) after 2 ns;
      data <= "00100111";
    end if;
	end process;
end SIM;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;

entity video_tb is
	port (
		fail:				out  boolean := false
	);
end video_tb;

architecture SYN of video_tb is
	signal clk			: std_logic	:= '0';
	signal reset		: std_logic	:= '1';

	-- inputs
	-- outputs
	signal strobe : std_logic;
	signal x : std_logic_vector(10 downto 0);
	signal y : std_logic_vector(10 downto 0);
	signal hblank : std_logic;
	signal vblank : std_logic;
	signal red : std_logic_vector(9 downto 0);
	signal green : std_logic_vector(9 downto 0);
	signal blue : std_logic_vector(9 downto 0);
	signal hsync : std_logic;
	signal vsync : std_logic;

	signal tilemap_a : std_logic_vector(15 downto 0);
	signal tilemap_d : std_logic_vector(15 downto 0);
	signal tile_a : std_logic_vector(15 downto 0);
	signal tile_d : std_logic_vector(7 downto 0);
	signal attr_a : std_logic_vector(9 downto 0);

	signal tilemap_a2 : std_logic_vector(15 downto 0);
	signal tilemap_d2 : std_logic_vector(15 downto 0);
	signal tile_a2 : std_logic_vector(15 downto 0);
	signal tile_d2 : std_logic_vector(7 downto 0);
	signal attr_a2 : std_logic_vector(9 downto 0);

	signal vid_outsel : std_logic := '0';
	signal vid_r : std_logic_vector(9 downto 0);
	signal vid_g : std_logic_vector(9 downto 0);
	signal vid_b : std_logic_vector(9 downto 0);
	signal pac_rgb : RGB_t;
	signal trs_rgb : RGB_t;
  signal lcm_data : std_logic_vector(9 downto 0);
	signal vclk : std_logic;

begin
	-- Generate CLK and reset
	--clk <= not clk after 12500 ps;
  clk <= not clk after 44899 ps; -- 11.136MHz
	reset <= '0' after 10 ns;

	-- Signals
	vid_r <= pac_rgb.r when vid_outsel = '0' else trs_rgb.r;
	vid_g <= pac_rgb.g when vid_outsel = '0' else trs_rgb.g;
	vid_b <= pac_rgb.b when vid_outsel = '0' else trs_rgb.b;

	process(vsync)
	begin
		if falling_edge(vsync) then
			vid_outsel <= not vid_outsel;
		end if;
	end process;

	-- Video Controller module
	VGAController_1 : entity work.pace_video_controller 
		generic map
		(
			CONFIG		=> PACE_VIDEO_CONTROLLER_TYPE,
			H_SIZE    => PACE_VIDEO_H_SIZE,
			V_SIZE    => PACE_VIDEO_V_SIZE,
			H_SCALE   => 2,
			V_SCALE   => 2
		)
		port map 
		(
			clk 				=> clk,
			clk_ena			=> '1',
			reset 			=> reset,
	
			rgb_i.r 		=> vid_r,
			rgb_i.g 		=> vid_g,
			rgb_i.b 		=> vid_b,
	
			stb 				=> strobe,
			x 					=> x,
			y 					=> y,
			--xcentre			=> (others => '0'),
			--ycentre			=> (others => '0'),
	
			video_o.clk					=> vclk,
			video_o.hblank 			=> hblank,
			video_o.vblank 			=> vblank,
			video_o.rgb.r 				=> red,
			video_o.rgb.g 			=> green,
			video_o.rgb.b 				=> blue,
			video_o.hsync 			=> hsync,
			video_o.vsync 			=> vsync
			--lcm_data		=> lcm_data
		);

  GEN_BITMAP1 : if true generate

    	-- Pacman map controller
    	bitmapCtl_invaders : entity work.bitmapCtl_1 
        port map (
      		clk 				=> clk,
      		clk_ena 		=> strobe,
      		reset 			=> reset,
      		-- video control signals		
      		hblank 			=> hblank,
      		vblank 			=> vblank,
      		pix_x 			=> x(9 downto 0),
      		pix_y 			=> y(9 downto 0),
          -- tilemap interface
          scroll_data => (others => '0'),
          palette_data => (others => (others => '0')),
          bitmap_d    => tilemap_d(7 downto 0),
          bitmap_a    => open, --tilemap_a,
      		-- RGB output (10-bits each)
      		rgb 				=> open --pac_rgb
      	);

  end generate GEN_BITMAP1;

  GEN_MAP1 : if false generate

    	-- Pacman map controller
    	--mapCtl_pacman : entity work.mapCtl_1 port map (
    	--	clk 				=> clk,
    	--	clk_ena 		=> strobe,
    	--	reset 			=> reset,
    		-- video control signals		
    	--	hblank 			=> hblank,
    	--	vblank 			=> vblank,
    	--	pix_x 			=> x,
    	--	pix_y 			=> y,
        -- tilemap interface
      --  tilemap_d   => tilemap_d,
      --  tilemap_a   => tilemap_a,
      --  tile_d      => tile_d,
      --  tile_a      => tile_a,
      --  attr_d      => (others => '0'),
      --  attr_a      => attr_a,
    		-- RGB output (10-bits each)
    	--	rgb 				=> pac_rgb
    	--);

  end generate GEN_MAP1;

  GEN_MAP3 : if false generate

  	-- TRS80 map controller
  	--mapCtl_trs80 : entity work.mapCtl_3 port map (
    --  clk         => clk,
  	--	clk_ena			=> strobe,
    --  reset       => reset,
  	--	--/ video control signals		
    --  hblank      => hblank,
    --  vblank      => vblank,
    --  pix_x       => x,
    --  pix_y       => y,
    --  -- tilemap interface
    --  tilemap_d   => tilemap_d2,
    --  tilemap_a   => tilemap_a2,
    --  tile_d      => tile_d2,
    --  tile_a      => tile_a2,
    --  attr_d      => (others => '0'),
    --  --.attr_a       (attr_a)
  	--	-- RGB output (10-bits each)
  	--	rgb					=> trs_rgb
  	--);

  end generate GEN_MAP3;

	tilemap_mem_1 : entity work.dummy_mem port map (
		clk         => clk,
		addr        => tilemap_a,
		data        => tilemap_d
	);

	tile_mem_1 : entity work.dummy_mem2  port map (
		clk         => clk,
		addr        => tile_a,
		data        => tile_d
	);
	
	tilemap_mem_2 : entity work.dummy_mem  port map (
		clk         => clk,
		addr        => tilemap_a2,
		data        => tilemap_d2
	);
	
	tile_mem_2 : entity work.dummy_mem2  port map (
		clk         => clk,
		addr        => tile_a2,
		data        => tile_d2
	);
		
end SYN;
