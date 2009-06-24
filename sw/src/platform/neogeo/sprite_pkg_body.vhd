library work;
use work.pace_pkg.all;
use work.sprite_pkg.all;

package body sprite_pkg is

  function NULL_TO_SPRITE_REG return to_SPRITE_REG_t is
  begin
    return ('0', '0', '0', (others => '0'), (others => '0'));
  end function NULL_TO_SPRITE_REG;

  function NULL_TO_SPRITE_CTL return to_SPRITE_CTL_t is
  begin
    return ('0', (others => '0'));
  end function NULL_TO_SPRITE_CTL;

  function flip_row
  (
    row_in      : SPRITE_ROW_D_t;
    flip        : std_logic
  )
  return SPRITE_ROW_D_t is
  
    constant HALF	    : natural := (SPRITE_ROW_D_t'length / 2) - 1;

    variable row_out  : SPRITE_ROW_D_t;
    
  begin

    if flip = '0' then
      return row_in;
    else
      GEN_FLIP : for i in 0 to HALF loop
        row_out ((HALF-i)*2+1 downto (HALF-i)*2) := row_in(i*2+1 downto i*2);
      end loop GEN_FLIP;
      return row_out;
    end if;
  
  end flip_row;

end package body sprite_pkg;
