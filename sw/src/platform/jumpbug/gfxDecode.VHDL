library IEEE;
use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;

entity gfxDecode is
port
(
    clk              : in     std_logic;
    reset            : in     std_logic;

    -- bank control
    bank_addr        : in     std_logic_vector(3 downto 0);
    bank_data        : in     std_logic;
    bank_wr          : in     std_logic;

    -- tile address and mux
    tile_addr_in     : in     std_logic_vector(12 downto 0);
    tile_addr_out    : out    std_logic_vector(12 downto 0);
    tile0_data       : in     std_logic_vector(7 downto 0);    -- 8K
    tile1_data       : in     std_logic_vector(7 downto 0);    -- 4K
    tile_data_out    : out    std_logic_vector(7 downto 0);

    -- sprite address and mux
    sprite_addr_in   : in     std_logic_vector(15 downto 0);
    sprite_addr_out  : out    std_logic_vector(10 downto 0);
    sprite0_data     : in     std_logic_vector(31 downto 0);    -- 8K
    sprite1_data     : in     std_logic_vector(31 downto 0);    -- 4K
    sprite_data_out  : out    std_logic_vector(31 downto 0)
) ;
end gfxDecode;

architecture beh of gfxDecode is
     signal tile_code : std_logic_vector(9 downto 0);
     signal sprite_code : std_logic_vector(7 downto 0);
     signal bank : std_logic_vector(7 downto 0);
begin
     process (clk, bank_wr)

     variable bank_r : std_logic_vector(7 downto 0);
     --variable tile_9_r : std_logic;
     --variable sprite_7_r : std_logic;

     begin
          if rising_edge(clk) then
             if reset = '1' then
                bank_r := X"00";
             else
                 if bank_wr = '1' then
                    case bank_addr is
                         when X"2" =>
                              bank_r(0) := bank_data;
                         when X"3" =>
                              bank_r(1) := bank_data;
                         when X"4" =>
                              bank_r(2) := bank_data;
                         when X"5" =>
                              bank_r(3) := bank_data;
                         when X"6" =>
                              bank_r(4) := bank_data;
                         when others =>
                    end case;
                 end if; -- bank_wr = '1'
             end if;
          end if;

          bank <= bank_r;

     end process;

     -- modify the tile code
     -- original tile code derived from tile_addr_in(11 downto 4)
     tile_code(9) <= not bank(4) when (tile_addr_in(11 downto 10) = "10" and bank(2) = '1') else '0';
     tile_code(8) <= bank(4) when (tile_addr_in(11 downto 10) = "10" and bank(2) = '1') else '0';
     tile_code(7 downto 6) <= (bank(1) & bank(0)) when (tile_addr_in(11 downto 10) = "10" and bank(2) = '1') else
                              tile_addr_in(11 downto 10);
     tile_code(5 downto 0) <= tile_addr_in (9 downto 4);

     -- generate the tile address
     tile_addr_out(12 downto 4) <= tile_code(8 downto 0);
     tile_addr_out(3 downto 0) <= tile_addr_in(3 downto 0);

     -- modify the sprite code
     -- original sprite code derived from sprite_addr_in(9 downto 4)
     sprite_code(7) <= not bank(4) when (sprite_addr_in(9 downto 8) = "10") and (bank(2) = '1') else '0';
     sprite_code(6) <= bank(4) when (sprite_addr_in(9 downto 8) = "10") and (bank(2) = '1') else '0';
     sprite_code(5 downto 4) <= (bank(1) & bank(0)) when (sprite_addr_in(9 downto 8) = "10") and (bank(2) = '1') else
                                sprite_addr_in(9 downto 8);
     sprite_code(3 downto 0) <= sprite_addr_in (7 downto 4);

     -- generate the sprite address
     sprite_addr_out(10 downto 4) <= sprite_code(6 downto 0);
     sprite_addr_out(3 downto 0) <= sprite_addr_in(3 downto 0);

     --tile_13_r := tile_code(9);
     --sprite_11_r := sprite_code(7);

     -- mux the tile data
     tile_data_out <= tile0_data;

     -- mux the sprite data
     sprite_data_out <= sprite0_data;

end beh;

