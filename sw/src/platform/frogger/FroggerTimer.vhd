library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

-- /* The timer clock in Frogger which feeds the upper 4 bits of         */
-- /* AY-3-8910 port A is based on the same clock                     */
-- /* feeding the sound CPU Z80.  It is a divide by                   */
-- /* 5120, formed by a standard divide by 512,                       */
-- /* followed by a divide by 10 using a 4 bit                        */
-- /* bi-quinary count sequence. (See LS90 data sheet                 */
-- /* for an example).                                                */
-- /*                                                     */
-- /* Bit 4 comes from the output of the divide by 1024               */
-- /*       0, 1, 0, 1, 0, 1, 0, 1, 0, 1                           */
-- /* Bit 3 comes from the QC output of the LS90 producing a sequence of */
-- /*      0, 0, 1, 1, 0, 0, 1, 1, 1, 0                         */
-- /* Bit 6 comes from the QD output of the LS90 producing a sequence of */
-- /*      0, 0, 0, 0, 1, 0, 0, 0, 0, 1                         */
-- /* Bit 7 comes from the QA output of the LS90 producing a sequence of */
-- /*      0, 0, 0, 0, 0, 1, 1, 1, 1, 1                         */
--
-- static int frogger_timer[10] =
-- {
--     0x00, 0x10, 0x08, 0x18, 0x40, 0x90, 0x88, 0x98, 0x88, 0xd0
-- };

entity froggerTimer is
port
(
    clk         : in     std_logic;
    reset       : in     std_logic;

    -- data
    datao       : out    std_logic_vector(7 downto 0)
) ;
end froggerTimer;

architecture beh of froggerTimer is
begin

     process (clk)

     variable count_r : std_logic_vector(8 downto 0);
     variable datao_r : std_logic_vector(3 downto 0);

     begin
          if rising_edge(clk) then
             if reset = '1' then
                count_r := "000000000";
                datao_r := X"0";
             else
                 if count_r = "111111111" then
                    if datao_r = X"9" then
                       datao_r := X"0";
                    else
                       datao_r := datao_r + 1;
                    end if;
                 end if;
                 count_r := count_r + 1;
             end if;

          end if;

     -- lookup table for the output
     case datao_r is
     when X"0" => datao <= X"00";
     when X"1" => datao <= X"10";
     when X"2" => datao <= X"08";
     when X"3" => datao <= X"18";
     when X"4" => datao <= X"40";
     when X"5" => datao <= X"90";
     when X"6" => datao <= X"88";
     when X"7" => datao <= X"98";
     when X"8" => datao <= X"88";
     when X"9" => datao <= X"D0";
     when others =>
     end case;

     end process;

end beh;

