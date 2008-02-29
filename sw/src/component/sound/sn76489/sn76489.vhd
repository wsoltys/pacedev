library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity tone_generator is
	port
	(
		clk						: in std_logic;
		clk_div16_en	: in std_logic;
		reset					: in std_logic;
              	
		freq        	: in std_logic_vector(9 downto 0);

		audio_out			: out std_logic
	);
end entity tone_generator;

architecture SYN of tone_generator is

begin

  -- the datasheet suggests that the frequency register is loaded
	-- into a 10-bit counter and decremented until it hits 0
	-- however, this results in a half-period of FREQ+1!

  process (clk, reset)
    variable count  : std_logic_vector(9 downto 0);
    variable tone   : std_logic;
  begin
    if reset = '1' then
      count := freq;
      tone := '0';
    elsif rising_edge(clk) then
      if clk_div16_en = '1' then
        if count = 0 then
          tone := not tone;
          count := freq;
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

	signal clk_div16_en		: std_logic;
  signal audio_d        : std_logic_vector(0 to 3);

	--signal shift_s				: std_logic;	-- debug only

begin

	process (clk, reset)
		variable count : std_logic_vector(3 downto 0) := (others => '0');
	begin
		if reset = '1' then
			count := (others => '0');
		elsif rising_edge(clk) then
			clk_div16_en <= '0';
			if clk_en = '1' then
				if count = 0 then
					clk_div16_en <= '1';
				end if;
				count := count + 1;
			end if;
		end if;
	end process;

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
        clk							=> clk,
        clk_div16_en		=> clk_div16_en,
        reset						=> reset,
                    
        freq        		=> reg(i*2),

        audio_out				=> audio_d(i)
      );

  end generate GEN_TONE_GENS;

  -- noise generator
  process (clk, reset)
    variable noise_r  		: std_logic_vector(14 downto 0);
		variable count				: std_logic_vector(6 downto 0);
		variable audio_d2_r		: std_logic; -- T3 output registered
		variable shift				: boolean;
  begin
    if reset = '1' then
      noise_r := (noise_r'left => '1', others => '0');
			count := (others => '0');
			shift := false;
    elsif rising_edge(clk) then
			shift := false;
      if clk_div16_en = '1' then
				case reg(NOISE_CTL)(9 downto 8) is
					when "00" =>
						shift := count(count'left-2 downto 0) = 0;
					when "01" =>
						shift := count(count'left-1 downto 0) = 0;
					when "10" =>
						shift := count(count'left downto 0) = 0;
					when others =>
						-- shift rate governed by T3 output?!?
						shift := audio_d(2) = '1' and audio_d2_r = '0';
				end case;
				if shift then
	    		noise_r := (noise_r(1) xor noise_r(0)) & noise_r(noise_r'left downto 1);
				end if;
				count := count + 1;
				audio_d2_r := audio_d(2);
      end if;
			--if shift then shift_s <= '1'; else shift_s <= '0'; end if; -- debug only
    end if;
    -- no attentuation atm
    audio_d(3) <= noise_r(0);
  end process;

  -- just T1 for now
  audio_out <= (others => audio_d(0));

end SYN;
