Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sound is 
  generic
  (
    CLK_MHz           : natural := 0
  );
  port
  (
    sysClk            : in    std_logic;
    reset             : in    std_logic;
    
    sndif_rd          : in    std_logic;
    sndif_wr          : in    std_logic;
    sndif_datai       : in    std_logic_vector(7 downto 0);
    sndif_addr        : in    std_logic_vector(15 downto 0);
    
    snd_clk           : out   std_logic;
    snd_data_l        : out   std_logic_vector(7 downto 0);
    snd_data_r        : out   std_logic_vector(7 downto 0);
    sndif_datao       : out   std_logic_vector(7 downto 0)
  );
  end entity Sound;

architecture SYN of Sound is

begin

  process (sysClk, reset)
    variable count : unsigned(2 downto 0);
  begin
    if reset = '1' then
      count := (others => '0');
    elsif rising_edge(sysClk) then
      count := count + 1;
      snd_clk <= count(count'left);
    end if;
  end process;
  
  gbc_snd_inst : entity work.gbc_snd
    port map
    (
      clk						=> sysClk,
      reset					=> reset,
      
      s1_read				=> sndif_rd,
      s1_write			=> sndif_wr,
      s1_addr				=> sndif_addr(5 downto 0),
      s1_readdata		=> sndif_datao,
      s1_writedata	=> sndif_datai,
      
      snd_left(15 downto 8)   => snd_data_l,
      snd_left(7 downto 0)    => open,
      snd_right(15 downto 8)  => snd_data_r,
      snd_right(7 downto 0)   => open
    );
     
end SYN;
