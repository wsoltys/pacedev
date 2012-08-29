Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

  process (clk, clk_ena)
  begin
    if rising_edge(clk) and clk_ena = '1' then
      if reg_i.a(5 downto 2) = std_logic_vector(to_unsigned(INDEX, 4)) then
        if reg_i.wr = '1' then
          if INDEX < 8 then
            -- normal sprites
            case reg_i.a(1 downto 0) is
              when "00" =>
                reg_o.y <= std_logic_vector(resize(unsigned(not reg_i.d), reg_o.y'length));
              when "01" =>
                reg_o.n <= std_logic_vector(resize(unsigned(reg_i.d(5 downto 0)), reg_o.n'length));
                reg_o.xflip <= reg_i.d(6);
                reg_o.yflip <= reg_i.d(7);
              when "10" =>
                reg_o.colour <= reg_i.d;
              when others =>
                reg_o.x <= std_logic_vector(resize(unsigned(reg_i.d), reg_o.x'length));
            end case;
          else
            -- bullets
            case reg_i.a(1 downto 0) is
              when "01" =>
                reg_o.y <= std_logic_vector(resize(unsigned(not reg_i.d), reg_o.y'length));
              when "11" =>
                reg_o.x <= std_logic_vector(resize(unsigned(not reg_i.d), reg_o.x'length));
              when others =>
                null;
            end case;
            reg_o.xflip <= '0';
            reg_o.yflip <= '0';
            reg_o.n <= (others => '0');
            if INDEX < 15 then
              -- white
              reg_o.colour <= std_logic_vector(to_unsigned(0,reg_o.colour'length));
            else
              -- yellow
              reg_o.colour <= std_logic_vector(to_unsigned(1,reg_o.colour'length));
            end if; -- INDEX<15
          end if; -- INDEX<8
        end if; -- reg_i.wr='1'
      end if; -- reg_i.a()=INDEX
    end if;
  end process;
				
  reg_o.pri <= '1';

end SYN;

