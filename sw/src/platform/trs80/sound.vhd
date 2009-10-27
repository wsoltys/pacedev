--------------------------------------------------------------------------------
-- SubModule Sound
-- Created   18/08/2005 6:39:14 PM
--------------------------------------------------------------------------------
Library IEEE;
Use IEEE.Std_Logic_1164.all;

entity Sound is 
  generic
  (
    CLK_MHz           : natural
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
     snd_data          : out   std_logic_vector(7 downto 0);
     sndif_datao       : out   std_logic_vector(7 downto 0)
   );
end Sound;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
architecture Structure of Sound is

-- Signal Declarations

begin

  process (reset, sysClk, sndif_wr)
    variable wr_v : std_logic;
    variable snd_data_v : std_logic_vector(1 downto 0);
  begin
    if reset = '1' then
       wr_v := '0';
       snd_data_v := "00";
    else
      if rising_edge(sysClk) then
        -- latch new xound value on a write
        if wr_v = '0' and sndif_wr = '1' then
          case sndif_datai(1 downto 0) is
            when "00" =>
              snd_data_v := "01";
            when "01" =>
              snd_data_v := "10";
            when others =>
              snd_data_v := "00";
          end case;
        end if;
        wr_v := sndif_wr;
      end if;
    end if;
    -- assign latched sound data to output
    snd_data <= snd_data_v & "000000";
  end process;

  -- create a (20/4) 5MHz sound clock
	process (reset, sysClk)
		variable count : integer range 0 to 4;
		variable clk_v : std_logic;
	begin
		if reset = '1' then
			clk_v := '0';
			count := 4;
		elsif rising_edge(sysClk) then
			count := count - 1;
			if count = 0 then
				clk_v := not clk_v;
				count := 4;
			end if;
		end if;
		-- assign to output
		snd_clk <= clk_v;
	end process;

  sndif_datao <= X"00";

end Structure;
--------------------------------------------------------------------------------
