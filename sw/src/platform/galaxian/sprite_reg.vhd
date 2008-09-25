Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.sprite_pkg.all;

entity sptReg is

	generic
	(
		INDEX			: natural
	);
	port
	(
    reg_i     : in to_SPRITE_REG_t;
    reg_o     : out from_SPRITE_REG_t
	);

end sptReg;

architecture SYN of sptReg is

  alias clk       : std_logic is reg_i.clk;
  alias clk_ena   : std_logic is reg_i.clk_ena;

begin

	GEN_SPRITE_REG : if INDEX < 8 generate
	
    process (clk, clk_ena)
    begin
      if rising_edge(clk) and clk_ena = '1' then
        if reg_i.a(5 downto 2) = conv_std_logic_vector(INDEX, 4) then
          if reg_i.wr = '1' then
            case reg_i.a(1 downto 0) is
              when "00" =>
                reg_o.x <= EXT(reg_i.d, reg_o.x'length);
              when "01" =>
                reg_o.n <= EXT(reg_i.d(5 downto 0), reg_o.n'length);
                reg_o.yflip <= reg_i.d(6);
                reg_o.xflip <= reg_i.d(7);
              when "10" =>
                reg_o.colour <= reg_i.d;
              when others =>
                reg_o.y <= EXT(reg_i.d, reg_o.y'length);
            end case;
          end if;
        end if;
      end if;
    end process;
    
	end generate GEN_SPRITE_REG;
				
	GEN_BULLET_REG : if INDEX > 7 generate
	--GEN_BULLET_REG : if false generate
	
    process (clk, clk_ena)
    begin
      if rising_edge(clk) and clk_ena = '1' then
        if reg_i.a(5 downto 2) = conv_std_logic_vector(INDEX, 4) then
          if reg_i.wr = '1' then
            case reg_i.a(1 downto 0) is
              when "01" =>
                reg_o.x <= EXT(reg_i.d, reg_o.x'length);
              when "11" =>
                reg_o.y <= EXT(not reg_i.d, reg_o.y'length);
              when others =>
                null;
            end case;
          end if;
        end if;
      end if;
    end process;
	
    reg_o.xflip <= '0';
    reg_o.yflip <= '0';
    reg_o.n <= (others => '0');

    GEN_BOMB_COLOUR : if INDEX < 15 generate
      -- white
      reg_o.colour <= std_logic_vector(conv_unsigned(0,reg_o.colour'length));
    end generate GEN_BOMB_COLOUR;

    GEN_BULLET_COLOUR : if INDEX = 15 generate
      -- yellow
      reg_o.colour <= std_logic_vector(conv_unsigned(1,reg_o.colour'length));
    end generate GEN_BULLET_COLOUR;

	end generate GEN_BULLET_REG;
				
  reg_o.pri <= '1';

end SYN;

