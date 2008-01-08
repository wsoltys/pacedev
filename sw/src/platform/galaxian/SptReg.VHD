Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity sptReg is

	generic
	(
		INDEX			: natural
	);
	port
	(
		clk				: in std_logic;
		wr				: in std_logic;
		din				: in std_logic_vector(7 downto 0);
		addr			: in std_logic_vector(1 downto 0);
		
		sptX			: out std_logic_vector(7 downto 0);
		sptY			: out std_logic_vector(8 downto 0);
		sptFlags	: out std_logic_vector(7 downto 0);
		sptColour	: out std_logic_vector(7 downto 0);
		sptNum 		: out std_logic_vector(11 downto 0);
		sptPri    : out std_logic
	);

end sptReg;

architecture SYN of sptReg is

	signal xFlip		: std_logic;
	signal yFlip		: std_logic;
	
begin

	--GEN_SPRITE_REG : if INDEX < 8 generate
	
    process (clk)
    begin
      if rising_edge(clk) then
        if wr = '1' then
          case addr is
            when "00" =>
              sptX <= din;
            when "01" =>
              sptNum <= "000000" & din(5 downto 0);
              yFlip <= din(6);
              xFlip <= din(7);
            when "10" =>
              SptColour <= din;
            when others =>
              sptY <= '0' & din;
          end case;
        end if;
      end if;
    end process;
    
    sptFlags <= "000000" & yFlip & xFlip;

	--end generate GEN_SPRITE_REG;
				
	--GEN_BULLET_REG : if INDEX > 7 generate
	GEN_BULLET_REG : if false generate
	
    process (clk)
    begin
      if rising_edge(clk) then
        if wr = '1' then
          case addr is
            when "01" =>
              sptX <= din;
            when "11" =>
              sptY <= '0' & not din;
            when others =>
              null;
          end case;
        end if;
      end if;
    end process;
	
    sptFlags <= (others => '0');
    sptNum <= (others => '0');

	GEN_BOMB_COLOUR : if INDEX < 15 generate
		-- white
		sptColour <= std_logic_vector(conv_unsigned(0,sptColour'length));
	end generate GEN_BOMB_COLOUR;

	GEN_BULLET_COLOUR : if INDEX = 15 generate
		-- yellow
		sptColour <= std_logic_vector(conv_unsigned(1,sptColour'length));
	end generate GEN_BULLET_COLOUR;

	end generate GEN_BULLET_REG;
				
  sptPri <= '1';

end SYN;

