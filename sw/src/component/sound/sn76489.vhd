library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity tone_generator is
	port
	(
		clk					: in std_logic;
		clk_en			: in std_logic;
		reset				: in std_logic;
              	
		freq        : in std_logic_vector(9 downto 0);
    attn        : in std_logic_vector(3 downto 0);

		audio_out		: out std_logic
	);
end entity tone_generator;

architecture SYN of tone_generator is

begin

  -- check for compatibility with freq = 0!

  process (clk, reset)
    variable count  : std_logic_vector(13 downto 0);
    variable tone   : std_logic;
  begin
    if reset = '1' then
      count := freq & "0000";
      tone := '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        if count = 0 then
          tone := not tone;
          count := freq & "0000";
        else
          count := count - 1;
        end if;
      end if;
    end if;
    -- assign output
    audio_out <= tone;
  end process;

end SYN;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity sn76489 is
  generic
  (
    AUDIO_RES   : natural := 16
  );
	port
	(
		clk					: in std_logic;
		clk_en			: in std_logic;
		reset				: in std_logic;
              	
		d						: in std_logic_vector(7 downto 0);
		ready				: out std_logic;
		we_n				: in std_logic;
		ce_n				: in std_logic;

		audio_out		: out std_logic_vector(AUDIO_RES-1 downto 0)
	);
end entity sn76489;

architecture SYN of sn76489 is

  type reg_t is array (natural range <>) of std_logic_vector(9 downto 0);
  signal reg  : reg_t(0 to 7);
  constant T1_FREQ      : natural := 0;
  constant T1_ATTN      : natural := 1;
  constant T2_FREQ      : natural := 2;
  constant T2_ATTN      : natural := 3;
  constant T3_FREQ      : natural := 4;
  constant T3_ATTN      : natural := 5;
  constant NOISE_CTL    : natural := 6;
  constant NOISE_ATTN   : natural := 7;

  signal audio_d        : std_logic_vector(0 to 3);

begin

  -- register interface
  process (clk, reset)
    variable reg_a  : integer range 0 to 7;
  begin
    if reset = '1' then
      reg <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if clk_en = '1' then
          -- data is strobed in on WE_n
        if we_n = '0' then
          if d(0) = '1' then
            reg_a := conv_integer(d(3 downto 1));
            -- always latch high nibble into R(9:6)
            reg(reg_a)(9 downto 6) <= d(7 downto 4);
          else
            case reg_a is
              when T1_FREQ | T2_FREQ | T3_FREQ =>
                reg(reg_a)(5 downto 0) <= d(7 downto 2);
              when others =>
                null;
            end case;
          end if; -- d(0) = 0/1
        end if; -- we_n = 0
      end if;
    end if;
  end process;

  GEN_TONE_GENS : for i in 0 to 2 generate

    tone_inst : entity work.tone_generator
      port map
      (
        clk					=> clk,
        clk_en			=> clk_en,
        reset				=> reset,
                    
        freq        => reg(i*2),
        attn        => reg(i*2+1)(9 downto 6),

        audio_out		=> audio_d(i)
      );

  end generate GEN_TONE_GENS;

  -- noise generator
  process (clk, reset)
    variable noise_r  : std_logic_vector(14 downto 0);
  begin
    if reset = '1' then
      noise_r := (noise_r'left => '1', others => '0');
    elsif rising_edge(clk) then
      if clk_en = '1' then
        noise_r := (noise_r(1) xor noise_r(0)) & noise_r(noise_r'left downto 1);
      end if;
    end if;
    -- no attentuation atm
    audio_d(3) <= noise_r(0);
  end process;

  -- just T1 for now
  audio_out <= (others => audio_d(0));

end SYN;
