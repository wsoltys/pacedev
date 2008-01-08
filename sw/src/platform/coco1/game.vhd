library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use	ieee.numeric_std.all;
use ieee.std_logic_arith.EXT;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;
use work.platform_pkg.all;

entity Game is
  port
  (
    -- clocking and reset
    clk         		: in std_logic_vector(0 to 3);
    reset           : in    std_logic;                       
    test_button     : in    std_logic;                       

    -- inputs
    ps2clk          : inout std_logic;                       
    ps2data         : inout std_logic;                       
    dip             : in    std_logic_vector(7 downto 0);    

    -- micro buses
    upaddr          : out   std_logic_vector(15 downto 0);   
    updatao         : out   std_logic_vector(7 downto 0);    

    -- SRAM
		sram_i					: in from_SRAM_t;
		sram_o					: out to_SRAM_t;

    gfxextra_data   : out std_logic_vector(7 downto 0);

    -- graphics (control)
    red							: out		std_logic_vector(7 downto 0);
		green						: out		std_logic_vector(7 downto 0);
		blue						: out		std_logic_vector(7 downto 0);
		hsync						: out		std_logic;
		vsync						: out		std_logic;

    cvbs            : out   std_logic_vector(7 downto 0);
			  
    -- sound
    snd_rd          : out   std_logic;                       
    snd_wr          : out   std_logic;
    sndif_datai     : in    std_logic_vector(7 downto 0);    

    -- spi interface
    spi_clk         : out   std_logic;                       
    spi_din         : in    std_logic;                       
    spi_dout        : out   std_logic;                       
    spi_ena         : out   std_logic;                       
    spi_mode        : out   std_logic;                       
    spi_sel         : out   std_logic;                       

    -- serial
    ser_rx          : in    std_logic;                       
    ser_tx          : out   std_logic;                       

    -- on-board leds
    leds            : out   std_logic_vector(7 downto 0)    
  );

end Game;

architecture SYN of Game is

	component palx4_clk IS
	PORT
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC 
		);
	END component;

	alias clk_20M					: std_logic is clk(0);
	alias clk_57M272			: std_logic is clk(1);
	
	-- clocks
	signal sys_clk				: std_logic;			-- 14M318
	signal clk_q					: std_logic;
	signal clk_e					: std_logic;
	
	signal cpu_reset			: std_logic;
	
	-- clock helpers
	signal falling_edge_q	: std_logic;
	signal falling_edge_e	: std_logic;
	signal sys_count			: std_logic_vector(3 downto 0);
  signal vdgclk         : std_logic;

  -- system signals
  signal sys_write      : std_logic;
	
	-- multiplexed address
	signal ma							: std_logic_vector(7 downto 0);

	signal mpu_addr				: std_logic_vector(15 downto 0);

  alias vdg_addr        : std_logic_vector(15 downto 0) is mpu_addr;
  signal vdg_data       : std_logic_vector(7 downto 0);
  signal vdg_y          : std_logic_vector(3 downto 0);						
  signal vdg_x          : std_logic_vector(4 downto 0);

  -- uP signals  
  alias uPclk          	: std_logic is clk_e;
  signal uP_addr        : std_logic_vector(15 downto 0);
  signal uP_datai       : std_logic_vector(7 downto 0);
  signal uP_datao       : std_logic_vector(7 downto 0);
  signal uPrdwr					: std_logic;
  signal uPvma					: std_logic;
  signal uPintreq       : std_logic;
  signal uPfintreq			: std_logic;
  signal uPnmireq       : std_logic;

  -- keyboard signals
	signal jamma_s				: JAMMAInputsType;
  signal kbd_matrix			: in8(0 to 8);
	alias game_reset			: std_logic is kbd_matrix(8)(0);
	
  -- PIA signals
  signal pia_datao  		: std_logic_vector(7 downto 0);
  signal pia_irqa      	: std_logic;
  signal pia_irqb      	: std_logic;
  signal pia_pa        	: std_logic_vector(7 downto 0);
  signal pia_ca1       	: std_logic;
  signal pia_ca2       	: std_logic;
  signal pia_pb        	: std_logic_vector(7 downto 0);
  signal pia_cb1       	: std_logic;
  signal pia_cb2       	: std_logic;

  signal pia_cs					: std_logic;

	-- SAM signals
  signal sam_cs					: std_logic;
  signal sam_datao			: std_logic_vector(7 downto 0);
                        
  -- ROM signals        
  signal rom_wr					: std_logic;
  signal rom_datao      : std_logic_vector(7 downto 0);
	signal rom_cs					: std_logic;

  -- EXTROM signals	                        
  signal extrom_datao   : std_logic_vector(7 downto 0);
	signal extrom_cs			: std_logic;

  -- VRAM signals       
  --signal vram_cs        : std_logic;
  signal vram_wr        : std_logic;
  --signal vram_datao     : std_logic_vector(7 downto 0);
                        
  -- RAM signals        
  signal ram_cs         : std_logic;
  signal ram_datao      : std_logic_vector(7 downto 0);

	-- system chipselect selector from SAM
	signal cs_sel					: std_logic_vector(2 downto 0);
	signal y              : std_logic_vector(7 downto 0);

  -- VDG signals
  signal vdg_reset      : std_logic;
  signal hs_n           : std_logic;
  signal fs_n           : std_logic;
  signal da0            : std_logic;
  signal vdg_sram_cs    : std_logic;

  -- only for test vga controller
	signal vga_clk_s				: std_logic;
	
begin

	cpu_reset <= reset or game_reset;
	
  --
  --  Clocking
  --

	-- produce a PAL clock (sys_clk) from the PLL output
	process (clk_57M272, reset)
		variable count : std_logic_vector(1 downto 0);
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk_57M272) then
			sys_clk <= count(1);
			count := count + 1;
		end if;
	end process;

	-- generate clock helpers
	process (sys_clk, reset, clk_e, clk_q)
		variable old_q	: std_logic;
		variable old_e	: std_logic;
	begin
		if reset = '1' then
			old_q := '0';
			old_e := '0';
		elsif falling_edge (sys_clk) then
			falling_edge_q <= '0';
			if old_q = '1' and clk_q = '0' then
				falling_edge_q <= '1';
			end if;
			old_q := clk_q;
			falling_edge_e <= '0';
			if old_e = '1' and clk_e = '0' then
				falling_edge_e <= '1';
				sys_count <= (others => '1');
			else
				sys_count <= sys_count + 1;
			end if;
			old_e := clk_e;
		end if;
	end process;

  -- need to sync reset to VDG with Q
  process (clk_q, reset)
  begin
    if reset = '1' then
      vdg_reset <= '1';
    elsif falling_edge (clk_q) then
      if reset = '0' then
        vdg_reset <= '0';
      end if;
    end if;
  end process;

  --	
	-- system control
  --

  -- assign chipselects from MC6883 selector output
  pia_cs <= y(4);
  extrom_cs <= y(1);
  rom_cs <= y(2);
	ram_cs <= y(0) or y(7);
  -- this is yet to be implemented in the 6883/6847
  --vram_cs <= '1' when uP_addr(15 downto 10) = "000001" else '0';

  ---
  --- yucky yucky yucky
  --- the cpu and MC6883 are running off falling_edge
  --- but the vram runs off rising_edge (ahh!!)
  ---

  -- runs off PAL clk (E x 16)
	process (sys_clk, sys_count)
	begin
		if falling_edge (sys_clk) then
			-- defaults
      sys_write <= '0';
      vdg_sram_cs <= '0';
      vram_wr <= '0';
			case sys_count is
        when X"0" =>
          -- latch VDG address (row)
          vdg_addr(7 downto 0) <= ma;
        when X"3" =>
          -- latch VDG address (column)
          vdg_addr(15 downto 8) <= ma;
        when X"4" =>
          -- read SRAM data here because we're multiplexing it with CPU
          vdg_sram_cs <= '1';
        when X"5" =>
      	  vdg_data <= sram_i.d(vdg_data'range);
				when X"6" =>
          if hs_n = '1' and fs_n = '1' then
            vram_wr <= '1';
          end if;
				when X"8" =>
          -- latch MPU address (row)
					mpu_addr(7 downto 0) <= ma;
				when X"B" =>
          -- latch MPU address (column)
					mpu_addr(15 downto 8) <= ma;
          -- enable bus write i/o
          sys_write <= '1';
				when X"C" =>
          -- read SRAM data here because we're multiplexing it with video
      	  ram_datao <= sram_i.d(ram_datao'range);
				when others =>
			end case;
		end if;
	end process;

  -- memory read mux
  uP_datai <= pia_datao when pia_cs = '1' else
              rom_datao when rom_cs = '1' else
              extrom_datao when extrom_cs = '1' else
              ram_datao when ram_cs = '1' else
              --vram_datao when vram_cs = '1' else
              X"FF";

  -- SRAM signals
  sram_o.a <= EXT(mpu_addr, sram_o.a'length);
  --sram_data <= uP_datao when (uPvma = '1' and ram_cs = '1' and uPrdwr = '0' and vdg_sram_cs = '0') 
  sram_o.d <= EXT(uP_datao, sram_o.d'length);
	sram_o.be <= EXT("1", sram_o.be'length);
  sram_o.cs <= (uPvma and ram_cs) or vdg_sram_cs;
	sram_o.oe <= uPrdwr or vdg_sram_cs;
	sram_o.we <= sys_write and not uPrdwr;

  -- CPU interrupts	
	uPintreq <= '0';
	uPfintreq <= '0';
	uPnmireq <= '0';

	-- PIA edge inputs
	pia_ca1 <= '0';
	pia_ca2 <= '0';
	pia_cb1 <= '0';
	pia_cb2 <= '0';
	--pia_pb <= (others => '0');
	
	-- keyboard matrix
	process (clk_20M, reset)
	  variable keys : std_logic_vector(7 downto 0);
	begin
	  if reset = '1' then
  		keys := (others => '0');
	  elsif rising_edge (clk_20M) then
  		keys := (others => '0');
  		-- note that row select is active low
  		if pia_pb(0) = '0' then
  			keys := keys or kbd_matrix(0);
  		end if;
  		if pia_pb(1) = '0' then
  			keys := keys or kbd_matrix(1);
  		end if;
  		if pia_pb(2) = '0' then
  			keys := keys or kbd_matrix(2);
  		end if;
  		if pia_pb(3) = '0' then
  			keys := keys or kbd_matrix(3);
  		end if;
  		if pia_pb(4) = '0' then
  			keys := keys or kbd_matrix(4);
  		end if;
  		if pia_pb(5) = '0' then
  			keys := keys or kbd_matrix(5);
  		end if;
  		if pia_pb(6) = '0' then
  			keys := keys or kbd_matrix(6);
  		end if;
  		if pia_pb(7) = '0' then
  			keys := keys or kbd_matrix(7);
  		end if;
	  end if;
	  -- key inputs are active low
	  pia_pa <= not keys;
	end process;

  gfxextra_data <= (others => '0');

  -- unused outputs
	upaddr <= uP_addr;
	updatao <= uP_datao;
  snd_rd <= '0';

  --
  --  COMPONENT INSTANTIATION
  --

	GEN_NOT_TEST_VGA : if not BUILD_TEST_VGA_ONLY generate
	
  cpu_inst : entity work.cpu09
	  port map
	  (	
			clk				=> clk_e,
			rst				=> cpu_reset,
			rw 	    	=> uPrdwr,
			vma 	    => uPvma,
			address 	=> uP_addr,
		  data_in		=> uP_datai,
		  data_out 	=> uP_datao,
			halt     	=> '0',
			hold     	=> '0',
			irq      	=> uPintreq,
			firq     	=> uPfintreq,
			nmi      	=> uPnmireq
	  );

	sam_inst : entity work.mc6883
		port map
		(
			clk				=> sys_clk,
			reset			=> reset,

			-- input
			a					=> uP_addr,
			rw_n			=> uPrdwr,

			-- vdg signals
			da0				=> da0,
			hs_n			=> hs_n,
			vclk		  => vdgclk,
			
			-- peripheral address selects		
			s					=> cs_sel,
			
			-- dynamic addresses
			z				  => ma,

			-- ram
			--ras0_n	: out std_logic;
			--cas_n		: out std_logic;
			--we_n		: out std_logic;
			
			-- clock generation
			q					=> clk_q,
			e					=> clk_e
		);

	U11_inst : entity work.ttl_74ls138_p
		port map
		(
			a			=> cs_sel(0),
			b			=> cs_sel(1),
			c			=> cs_sel(2),
			
			g1		=> '1',
			g2a		=> '1',
			g2b		=> '1',

      y     => y			
		);

  vdg_inst : entity work.mc6847
		generic map
		(
			char_rom_file => COCO1_SOURCE_ROOT_DIR & "roms/tiledata.hex"
		)
    port map
    (
      --clk     => vdgclk,
			clk			=> sys_clk,
      reset   => vdg_reset,

      hs_n    => hs_n,
      fs_n    => fs_n,
      da0     => da0,

			dd			=> vdg_data,
				
			red			=> red,
			green		=> green,
			blue		=> blue,
			hsync		=> hsync,
			vsync		=> vsync,

      cvbs    => cvbs
    );

  -- PIA (keyboard)
  pai_ub_inst : entity work.pia6821
  	port map
  	(	
  	 	clk       	=> uPclk,
      rst       	=> reset,
      cs        	=> pia_cs,
      rw        	=> uPrdwr,
      addr      	=> uP_addr(1 downto 0),
      data_in   	=> uP_datao,
  		data_out  	=> pia_datao,
  		irqa      	=> pia_irqa,
  		irqb      	=> pia_irqb,
  		pa_i        => pia_pa,
			pa_o				=> open,
			pa_oe				=> open,
  		ca1       	=> pia_ca1,
  		ca2_i      	=> pia_ca2,
			ca2_o				=> open,
			ca2_oe			=> open,
			pb_i				=> (others => 'X'),
  		pb_o       	=> pia_pb,
			pb_oe				=> open,
  		cb1       	=> pia_cb1,
  		cb2_i      	=> pia_cb2,
			cb2_o				=> open,
			cb2_oe			=> open
  	);

 kbd_inst : entity work.inputs
	generic map
	(
		NUM_INPUTS	=> kbd_matrix'length,
		CLK_1US_DIV	=> 20
	)
	port map
  (
	    clk     		=> clk_20M,
	    reset   		=> reset,
	    ps2clk  		=> ps2clk,
	    ps2data 		=> ps2data,
			jamma				=> jamma_s,

	    dips				=> dip,
	    inputs			=> kbd_matrix
	);

  -- COLOR BASIC ROM
  basrom_inst : entity work.sprom
		generic map
		(
			init_file		=> COCO1_SOURCE_ROOT_DIR & "roms/bas10.hex",
			numwords_a	=> 8192,
			widthad_a		=> 13
		)
  	port map
  	(
  		clock		    => sys_clk,
  		address		  => uP_addr(12 downto 0),
  		q			      => rom_datao
  	);

	GEN_EXT : if EXTENDED_COLOR_BASIC generate
	  -- EXTENDED COLOR BASIC ROM
	  extbasrom_inst : entity work.sprom
			generic map
			(
				init_file		=> COCO1_SOURCE_ROOT_DIR & "roms/extbas10.hex",
				numwords_a	=> 8192,
				widthad_a		=> 13
			)
	  	port map
	  	(
	  		clock		    => sys_clk,
	  		address		  => uP_addr(12 downto 0),
	  		q			      => extrom_datao
	  	);

	end generate GEN_EXT;

	end generate GEN_NOT_TEST_VGA;

	GEN_TEST_VGA : if BUILD_TEST_VGA_ONLY generate
	
		--vga_clk_inst : vga_clk
		--	PORT map
		--	(
		--		inclk0		=> ref_clk,
		--		c0				=> vga_clk_s
		--	);

    --vga_inst : vga_controller
    --	port map
    --	(
    --		--clk			  => vga_clk_s,
    --		clk			  => sys_clk,
    --		reset		  => reset
   -- 
   --     -- output
   --     --hsync     => hsync,
   --     --vsync		  => vsync,
   -- 
   --     --red       => red(7 downto 6),
   --     --green     => green(7 downto 6),
   --     --blue      => blue(7 downto 6)
   -- 	);

	end generate GEN_TEST_VGA;
		
end SYN;
