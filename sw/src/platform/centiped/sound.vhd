library IEEE;
use IEEE.Std_Logic_1164.all;

entity Sound is 
	port
  (
  	sysClk            : in    std_logic;
    reset             : in    std_logic;

    sndif_rd          : in    std_logic;
    sndif_wr          : in    std_logic;
    sndif_datai       : in    std_logic_vector(7 downto 0);
    sndif_addr        : in    std_logic_vector(15 downto 0);

    snd_clk           : out   std_logic;
    snd_data          : out   std_logic_vector(7 downto 0);
    sndif_datao       : out   std_logic_vector(7 downto 0)
	);
end Sound;

architecture SYN of Sound is

	alias clk_30M				: std_logic is sysClk;
	signal clk_1M5_en		: std_logic;
	signal sndif_wr_n		: std_logic;
	
begin

	sndif_wr_n <= not sndif_wr;
	
  snd_clk <= clk_1M5_en;

	-- generate POKEY clock enable (1M5Hz from 30MHz)
	clk_en_inst : entity work.clk_div
		generic map
		(
			DIVISOR		=> 20
		)
		port map
		(
			clk				=> clk_30M,
			reset			=> reset,
			clk_en		=> clk_1M5_en
		);

	pokey_inst : entity work.ASTEROIDS_POKEY
  	port map
		(
		  ADDR      		=> sndif_addr(3 downto 0),
		  DIN       		=> sndif_datai,
		  DOUT      		=> sndif_datao,
		  DOUT_OE_L 		=> open,
		  RW_L      		=> sndif_wr_n,
		  CS        		=> '1',
		  CS_L      		=> '0',
		  --
		  AUDIO_OUT 		=> snd_data,
		  --
		  PIN       		=> (others => '0'),
		  ENA       		=> clk_1M5_en,
		  CLK       		=> clk_30M
	  );
     
end SYN;
