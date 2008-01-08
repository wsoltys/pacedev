--
-- stereo PWM codec for Minimig P2 port
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity a_codec is
  port
  (
    iCLK          : in std_logic;
    iMUTE         : in std_logic;
    iSL           : in std_logic_vector(15 downto 0);
    iSR           : in std_logic_vector(15 downto 0);
    oAUD_XCK      : out std_logic;
    oAUD_DATA     : out std_logic;
    oAUD_LRCK     : out std_logic;
    oAUD_BCK      : out std_logic
  );
end a_codec;

architecture SYN of a_codec is

	-- fudge
	alias audio_left		: std_logic is oAUD_XCK;
	alias audio_right		: std_logic is oAUD_DATA;

begin

  -- audio PWM
  -- clock is 24Mhz, sample rate 24kHz
  process (iCLK)
    variable count : integer range 0 to 1023;
    variable audio_sample_l : std_logic_vector(9 downto 0);
    variable audio_sample_r : std_logic_vector(9 downto 0);
  begin
    if rising_edge(iCLK) then
      if count = 1023 then
        -- 24kHz tick - latch a sample (only 10 bits or 1024 steps)
        audio_sample_l := iSL(iSL'left downto iSL'left-9);
        audio_sample_r := iSR(iSR'left downto iSR'left-9);
        count := 0;
      else
        audio_left <= '0';  -- default
        audio_right <= '0'; -- default
        if audio_sample_l > count then
          audio_left <= '1';
        end if;
        if audio_sample_r > count then
          audio_right <= '1';
        end if;
        count := count + 1;
      end if;
    end if;
  end process;
  
end SYN;
