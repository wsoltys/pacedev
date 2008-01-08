library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.all;

entity sound is
port
(
    sysclk             : in     std_logic;
    reset              : in     std_logic;

    -- inputs
    sndif_addr         : in     std_logic_vector(15 downto 0);
    sndif_datai        : in     std_logic_vector(7 downto 0);
    sndif_rd           : in     std_logic;
    sndif_wr           : in     std_logic;

    -- outputs
    sndif_datao        : out    std_logic_vector(7 downto 0);
    snd_data           : out    std_logic_vector(7 downto 0);
    snd_clk            : out    std_logic
);
end sound;

architecture SYN of sound is

begin
    process (sysclk, reset)

    variable snd_clk_cntr : std_logic_vector(2 downto 0);
    variable snd_state_r  : std_logic;
    variable sndif_wr_r   : std_logic;

    begin
			if reset = '1' then
      	-- sound clock (nominally) 5Mhz
        snd_clk_cntr := "010"; -- -6
        snd_state_r := '0';
        sndif_wr_r := '0';
      elsif rising_edge (sysclk) then
				-- inc snd_clk counter
        if snd_clk_cntr = "000" then
        	snd_clk_cntr := "010"; -- -6
          snd_clk <= '1';
        else
          snd_clk_cntr := snd_clk_cntr + 1;
          snd_clk <= '0';
        end if;

        -- handle writing (latch on leading edge only)
        if sndif_wr = '1' and sndif_wr_r = '0' then
          snd_state_r := not snd_state_r;
        end if;

        sndif_wr_r := sndif_wr;
      end if;

      	snd_data <= snd_state_r & "0000000";
       	sndif_datao <= X"00";

    end process;

end SYN;
