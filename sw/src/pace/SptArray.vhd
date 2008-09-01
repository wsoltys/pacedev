library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

entity sptArray is

	port
	(
		clk					: in std_logic;
		clk_ena			: in std_logic;
		reset				: in std_logic;
		
    bank_data   : in std_logic_vector(7 downto 0);
				
		hblank			: in std_logic;
		xAddr				: in std_logic_vector(7 downto 0);
		yAddr				: in std_logic_vector(8 downto 0);
		dIn					: in std_logic_vector(7 downto 0);
		spriteAddr	: out std_logic_vector(15 downto 0);
		spriteData	: in std_logic_vector(31 downto 0);
		sprite_wr		: in std_logic;
		sprRegAddr	: in std_logic_vector(7 downto 0);
		
		rgb					: out RGB_t;
		spr_on			: out std_logic;
		spr_pri			: out std_logic;
		spr0_on			: out std_logic
	);

end sptArray;

architecture SYN of sptArray is

	type regWrTyp is array(natural range <>) of std_logic;
	type sptXTyp is array(natural range <>) of std_logic_vector(7 downto 0);
	type sptYTyp is array(natural range <>) of std_logic_vector(8 downto 0);
	type sptFlagsTyp is array(natural range <>) of std_logic_vector(7 downto 0);
	type sptColourTyp is array(natural range <>) of std_logic_vector(7 downto 0);
	type sptNumTyp is array(natural range <>) of std_logic_vector(11 downto 0);
	type sptPriTyp is array(natural range <>) of std_logic;
	type sptAddrTyp is array (natural range <>) of std_logic_vector(15 downto 0);
	
	signal regWr			: regWrTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptX				: sptXTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptY				: sptYTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptFlags		: sptFlagsTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptColour	: sptColourTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptNum			: sptNumTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptPri			: sptPriTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
	signal sptRowAddr : sptAddrTyp(0 to PACE_VIDEO_NUM_SPRITES-1);
		
	signal sptEna			: std_logic_vector(PACE_VIDEO_NUM_SPRITES-1 downto 0);
	signal sptRGB			: RGBArrayType(PACE_VIDEO_NUM_SPRITES-1 downto 0);
	signal sptOn			: std_logic_vector(PACE_VIDEO_NUM_SPRITES-1 downto 0);
	
begin

	-- Generate sprite register write signals	
	GEN_REG_WR : for i in 0 to PACE_VIDEO_NUM_SPRITES-1 generate
		-- WARNING: should be log2(NUM_SPRITES)
		regWr(i) <= sprite_wr when sprRegAddr(7 downto 2) = conv_std_logic_vector(i, 6) else '0';
	end generate GEN_REG_WR;
	
	-- Sprite Data Load Arbiter
	-- - enables each sprite controller during hblank
	--   to allow loading of sprite row data into row buffer
	process (clk, clk_ena, reset, sptRowAddr)
		variable i : integer range 0 to PACE_VIDEO_NUM_SPRITES-1;
		variable ena_s : std_logic_vector(PACE_VIDEO_NUM_SPRITES-1 downto 0);
	begin
		if reset = '1' then
			-- enable must be 1 clock behind address to latch data after fetch
			ena_s := (PACE_VIDEO_NUM_SPRITES-1 => '1', others => '0');
			i := 0;
		elsif rising_edge(clk) and clk_ena = '1' then
			ena_s := ena_s(ena_s'left-1 downto 0) & ena_s(ena_s'left);
			i := i + 1;
		end if;
		spriteAddr <= sptRowAddr(i);
		sptEna <= ena_s;
	end process;

	-- Sprite Priority Encoder
	-- - determines which sprite pixel (if any) is to be displayed
	-- We can use a clocked process here because the tilemap
	-- output is 1 clock behind at this point
	process (clk, clk_ena)
		variable spr_on_v 	: std_logic := '0';
		variable spr_pri_v 	: std_logic := '0';
	begin
		if rising_edge(clk) and clk_ena = '1' then
			spr_on_v := '0';
			spr_pri_v := '0';
			for i in 0 to PACE_VIDEO_NUM_SPRITES-1 loop
				-- if highest priority = 0 and pixel on
				if spr_pri_v = '0' and sptOn(i) = '1' then
					-- if no sprite on or this priority = 1
					if spr_on_v = '0' or sptPri(i) = '1' then
						rgb <= sptRGB(i);
						spr_on_v := '1';					-- flag as sprite on
						spr_pri_v := sptPri(i);		-- store priority
					end if;
				end if;
			end loop;
		end if;
		spr_on <= spr_on_v;
		spr_pri <= spr_pri_v;
	end process;

	-- for NES, and perhaps others
	spr0_on <= sptOn(0);
		
	--
	-- Component Instantiation
	--
	
	GEN_REGS : for i in 0 to PACE_VIDEO_NUM_SPRITES-1 generate
	
		sptReg_inst : entity work.sptReg
			generic map
			(
				INDEX			=> i
			)
			port map
			(
				clk				=> clk,				-- this should be uP clk domain!
				wr				=> regWr(i),
				din				=> dIn,
				addr			=> sprRegAddr(1 downto 0),
				
				sptX			=> sptX(i),
				sptY			=> sptY(i),
				sptFlags	=> sptFlags(i),
				sptColour	=> sptColour(i),
				sptNum 		=> sptNum(i),
				sptPri		=> sptPri(i)
			);

		sptCtl_inst : entity work.sptCtlVHDL
			generic map
			(
				INDEX			=> i
			)
			port map
			(
		    clk     	=> clk,
				clk_ena		=> clk_ena,

		    HBlank  	=> HBlank,
		    xAddr   	=> xAddr,
		    yAddr   	=> yAddr,
		    pixOn   	=> sptOn(i),
				rgb				=> sptRGB(i),

        bank_data => bank_data,
						    
		    num     	=> sptNum(i),
		    xLoc    	=> sptX(i),
		    yLoc    	=> sptY(i),
		    colour		=> sptColour(i),
		    flags   	=> sptFlags(i),

		    ena     	=> sptEna(i),
		    rowData 	=> spriteData,
		    rowAddr 	=> sptRowAddr(i)
			);
				
	end generate GEN_REGS;
	
end SYN;

