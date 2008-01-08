--------------------------------------------------------------------------------
-- SubModule Sound
-- Created   18/08/2005 6:39:14 PM
--------------------------------------------------------------------------------
Library IEEE;
Use IEEE.Std_Logic_1164.all;

entity Sound is port
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
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
architecture Structure of Sound is

-- Component Declarations

-- Signal Declarations

begin

     snd_clk <= '0';
     snd_data <= X"00";
     sndif_datao <= X"00";
     
end Structure;
--------------------------------------------------------------------------------
