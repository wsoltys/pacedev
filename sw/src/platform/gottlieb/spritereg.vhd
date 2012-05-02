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

	process (clk)
    variable i : integer range 0 to 63;
	begin
    -- sprite registers $3000-$30FF, 4 bytes per sprite
    i := to_integer(unsigned(reg_i.a(7 downto 2)));
		if rising_edge(clk) then
      if i = INDEX then
        if reg_i.wr = '1' then
          case reg_i.a(1 downto 0) is
            when "00" =>
              reg_o.y <= std_logic_vector(RESIZE(unsigned(reg_i.d), reg_o.y'length));
            when "01" =>
              reg_o.x <= std_logic_vector(RESIZE(unsigned(reg_i.d), reg_o.x'length));
            when "10" =>
              -- from MAME
              reg_o.n <= std_logic_vector(RESIZE(unsigned(X"FF" xor reg_i.d), reg_o.n'length));
            when others =>
              null;
          end case;
        end if;
      end if;
		end if;
	end process;
	
  -- usused bits
  reg_o.xflip <= '0';
  reg_o.yflip <= '0';
  reg_o.colour <= (others => '0');
  
  reg_o.pri <= '1';

end SYN;

