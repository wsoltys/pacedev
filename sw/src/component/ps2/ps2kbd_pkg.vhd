library ieee;
use ieee.std_logic_1164.all;

package kbd_pkg is
  
  constant SCANCODE_BACKQUOTE  : std_logic_vector(7 downto 0) := X"0E";    -- '`' TRS(@)
  constant SCANCODE_A          : std_logic_vector(7 downto 0) := X"1C";    -- 'A'
  constant SCANCODE_B          : std_logic_vector(7 downto 0) := X"32";    -- 'B'
  constant SCANCODE_C          : std_logic_vector(7 downto 0) := X"21";    -- 'C'
  constant SCANCODE_D          : std_logic_vector(7 downto 0) := X"23";    -- 'D'
  constant SCANCODE_E          : std_logic_vector(7 downto 0) := X"24";    -- 'E'
  constant SCANCODE_F          : std_logic_vector(7 downto 0) := X"2B";    -- 'F'
  constant SCANCODE_G          : std_logic_vector(7 downto 0) := X"34";    -- 'G'
  constant SCANCODE_H          : std_logic_vector(7 downto 0) := X"33";    -- 'H'
  constant SCANCODE_I          : std_logic_vector(7 downto 0) := X"43";    -- 'I'
  constant SCANCODE_J          : std_logic_vector(7 downto 0) := X"3B";    -- 'J'
  constant SCANCODE_K          : std_logic_vector(7 downto 0) := X"42";    -- 'K'
  constant SCANCODE_L          : std_logic_vector(7 downto 0) := X"4B";    -- 'L'
  constant SCANCODE_M          : std_logic_vector(7 downto 0) := X"3A";    -- 'M'
  constant SCANCODE_N          : std_logic_vector(7 downto 0) := X"31";    -- 'N'
  constant SCANCODE_O          : std_logic_vector(7 downto 0) := X"44";    -- 'O'
  constant SCANCODE_P          : std_logic_vector(7 downto 0) := X"4D";    -- 'P'
  constant SCANCODE_Q          : std_logic_vector(7 downto 0) := X"15";    -- 'Q'
  constant SCANCODE_R          : std_logic_vector(7 downto 0) := X"2D";    -- 'R'
  constant SCANCODE_S          : std_logic_vector(7 downto 0) := X"1B";    -- 'S'
  constant SCANCODE_T          : std_logic_vector(7 downto 0) := X"2C";    -- 'T'
  constant SCANCODE_U          : std_logic_vector(7 downto 0) := X"3C";    -- 'U'
  constant SCANCODE_V          : std_logic_vector(7 downto 0) := X"2A";    -- 'V'
  constant SCANCODE_W          : std_logic_vector(7 downto 0) := X"1D";    -- 'W'
  constant SCANCODE_X          : std_logic_vector(7 downto 0) := X"22";    -- 'X'
  constant SCANCODE_Y          : std_logic_vector(7 downto 0) := X"35";    -- 'Y'
  constant SCANCODE_Z          : std_logic_vector(7 downto 0) := X"1A";    -- 'Z'
  constant SCANCODE_0          : std_logic_vector(7 downto 0) := X"45";    -- '0'
  constant SCANCODE_1          : std_logic_vector(7 downto 0) := X"16";    -- '1'
  constant SCANCODE_2          : std_logic_vector(7 downto 0) := X"1E";    -- '2'
  constant SCANCODE_3          : std_logic_vector(7 downto 0) := X"26";    -- '3'
  constant SCANCODE_4          : std_logic_vector(7 downto 0) := X"25";    -- '4'
  constant SCANCODE_5          : std_logic_vector(7 downto 0) := X"2E";    -- '5'
  constant SCANCODE_6          : std_logic_vector(7 downto 0) := X"36";    -- '6'
  constant SCANCODE_7          : std_logic_vector(7 downto 0) := X"3D";    -- '7'
  constant SCANCODE_8          : std_logic_vector(7 downto 0) := X"3E";    -- '8'
  constant SCANCODE_9          : std_logic_vector(7 downto 0) := X"46";    -- '9'
  constant SCANCODE_QUOTE      : std_logic_vector(7 downto 0) := X"52";    -- ''' TRS(:)
  constant SCANCODE_SEMICOLON  : std_logic_vector(7 downto 0) := X"4C";    -- ';'
  constant SCANCODE_COMMA      : std_logic_vector(7 downto 0) := X"41";    -- ','
  constant SCANCODE_MINUS      : std_logic_vector(7 downto 0) := X"4E";    -- '-' TRS(_)
  constant SCANCODE_PERIOD     : std_logic_vector(7 downto 0) := X"49";    -- '.'
  constant SCANCODE_SLASH      : std_logic_vector(7 downto 0) := X"4A";    -- '/'
  constant SCANCODE_ENTER      : std_logic_vector(7 downto 0) := X"5A";    -- ENTER
  constant SCANCODE_HOME       : std_logic_vector(7 downto 0) := X"6C";    -- HOME TRS(CLR) (EX)
  constant SCANCODE_INS        : std_logic_vector(7 downto 0) := X"70";    -- INS TRS(BREAK) (EX)
  constant SCANCODE_UP         : std_logic_vector(7 downto 0) := X"75";    -- UP
  constant SCANCODE_DOWN       : std_logic_vector(7 downto 0) := X"72";    -- DOWN
  constant SCANCODE_LEFT       : std_logic_vector(7 downto 0) := X"6B";    -- LEFT
  constant SCANCODE_BACKSPACE  : std_logic_vector(7 downto 0) := X"66";    -- BACKSPACE
  constant SCANCODE_RIGHT      : std_logic_vector(7 downto 0) := X"74";    -- RIGHT
  constant SCANCODE_SPACE      : std_logic_vector(7 downto 0) := X"29";    -- SPACEBAR
  constant SCANCODE_LSHIFT     : std_logic_vector(7 downto 0) := X"12";    -- SHIFT (LEFT)
  constant SCANCODE_RSHIFT     : std_logic_vector(7 downto 0) := X"59";    -- SHIFT (RIGHT)
  constant SCANCODE_TAB					: std_logic_vector(7 downto 0) := X"0D";    -- TAB
  constant SCANCODE_ESC					: std_logic_vector(7 downto 0) := X"76";    -- ESC
  constant SCANCODE_EQUALS			: std_logic_vector(7 downto 0) := X"55";    -- '=+'
	constant SCANCODE_F1					: std_logic_vector(7 downto 0) := X"05";		-- F1
	constant SCANCODE_F2					: std_logic_vector(7 downto 0) := X"06";		-- F2
	constant SCANCODE_F3					: std_logic_vector(7 downto 0) := X"04";		-- F3
	constant SCANCODE_F4					: std_logic_vector(7 downto 0) := X"0C";		-- F4
	constant SCANCODE_F5					: std_logic_vector(7 downto 0) := X"03";		-- F5
	constant SCANCODE_F6					: std_logic_vector(7 downto 0) := X"0B";		-- F6
	constant SCANCODE_F7					: std_logic_vector(7 downto 0) := X"83";		-- F7
	constant SCANCODE_F8					: std_logic_vector(7 downto 0) := X"0A";		-- F8
	constant SCANCODE_F9					: std_logic_vector(7 downto 0) := X"01";		-- F9
	constant SCANCODE_F10					: std_logic_vector(7 downto 0) := X"09";		-- F10
	constant SCANCODE_F11					: std_logic_vector(7 downto 0) := X"78";		-- F11
	constant SCANCODE_F12					: std_logic_vector(7 downto 0) := X"07";		-- F12
	
  constant SCANCODE_LCTRL      	: std_logic_vector(7 downto 0) := X"14";
	constant SCANCODE_LALT				: std_logic_vector(7 downto 0) := X"11";
	
  type kbd_row is array (natural range <>) of std_logic_vector(7 downto 0);
  type kbd_col is array (natural range <>) of std_logic_vector(7 downto 0);

  -- for multi-inputs
  type in8 is array (natural range <>) of std_logic_vector(7 downto 0);

end;
