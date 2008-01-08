library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity intGen is
port
(
    clk       : in     std_logic;
    reset     : in     std_logic;

    -- inputs
    --vsync_n   : in     std_logic;
    --intack    : in     std_logic;

    -- outputs
    vblank    : out    std_logic;
    flash     : out    std_logic;
    irq_n     : out    std_logic
);
end intGen;

architecture beh of intGen is

begin
    process (clk)

    variable vsync_count   : std_logic_vector(18 downto 0);
    variable vblank_count  : std_logic_vector(15 downto 0);
    variable vblank_r      : std_logic;
    variable flash_count   : std_logic_vector(5 downto 0);
    variable irq_count     : std_logic_vector(15 downto 0);
    variable irq_r         : std_logic;

    begin
       if rising_edge (clk) then
          if reset = '1' then
             -- vsync every 60Hz = 500,000 @30MHz
             -- -500,000 = $5EE0
             vsync_count := "000" & X"5EE0";
             -- vblank 1460us
             vblank_count := X"54E8";
             vblank_r := '0';
             -- character flash
             flash_count := "000000";
             -- irq 20us
             irq_count := X"3CB0";
             irq_r := '0';
          else
              -- inc vsync counter
              if vsync_count = "000" & X"0000" then
                 vsync_count := "000" & X"5EE0";
                 vblank_count := X"54E8";
                 vblank_r := '1';
                 -- inc the character flash counter
                 flash_count := flash_count + 1;
              else
                 -- time for an irq (scanline #190?)
                 if vsync_count = "111" & X"EBA8" then
                    irq_count := X"3CB0";
                    irq_r := '1';
                 end if;
                 vsync_count := vsync_count + 1;
              end if;

              -- inc vblank counter
              if vblank_count = X"0000" then
                  vblank_r := '0';
              else
                  vblank_count := vblank_count + 1;
              end if;

              -- inc irq counter
              if irq_count = X"00" then
                 irq_r := '0';
              else
                 irq_count := irq_count + 1;
              end if;

          end if;
       end if;

       vblank <= vblank_r;
       -- characters flash for 32 out of every 64 vertical scans
       flash <= flash_count(5);
       irq_n <= not irq_r;

    end process;

end beh;


