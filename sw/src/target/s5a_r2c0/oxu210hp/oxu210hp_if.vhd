library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

entity oxu210hp_if is
  port
	(
    nios_clk                  : in std_logic;
    nios_rst                  : in std_logic;

	  -- NIOS interface
    avs_s0_address            : in std_logic_vector(16 downto 2);
    avs_s0_readdata           : out std_logic_vector(31 downto 0);
    avs_s0_writedata          : in std_logic_vector(31 downto 0);
    avs_s0_chipselect         : in std_logic;
    avs_s0_read               : in std_logic;
    avs_s0_write              : in std_logic;
    avs_s0_byteenable         : in std_logic_vector(3 downto 0);
    avs_s0_waitrequest        : out std_logic;
    avs_s0_irq                : out std_logic;

		-- physical interface
		coe_uh_reset_n            : out std_logic;
		coe_uh_a				          : out std_logic_vector(16 downto 1);
		coe_uh_d				          : inout std_logic_vector(31 downto 0);
		coe_uh_cs_n			          : out std_logic;
		coe_uh_rd_n			          : out std_logic;
		coe_uh_wr_n			          : out std_logic;
		coe_uh_be                 : out std_logic_vector(3 downto 0);
		coe_uh_int_n		          : in std_logic;
		coe_uh_dreq		            : in std_logic_vector(1 downto 0);
		coe_uh_dack			          : out std_logic_vector(1 downto 0)
  );
end entity oxu210hp_if;

architecture SYN of oxu210hp_if is

  signal coe_uh_d_i   : std_logic_vector(coe_uh_d'range);
  signal coe_uh_d_o   : std_logic_vector(coe_uh_d'range);
  signal coe_uh_d_oe  : std_logic;

  type state_t is ( S_IDLE, S_RD_1, S_RD_2, S_RD_3, S_WR_1, S_WR_2, S_WR_3 );
  signal state : state_t := S_IDLE;

begin

  -- NOTE: everything here assumes a 72MHz (~13.9ns) nios_clk
	--        *** CN updated timing for 83.3MHz (12ns)
  --        and OXU210HP is 120MHz (default)
  
  process (nios_clk, nios_rst)
    variable count : integer range 0 to 7 := 0;
  begin
    if nios_rst = '1' then
      coe_uh_d_oe <= '0';
      coe_uh_cs_n <= '1';
      coe_uh_rd_n <= '1';
      coe_uh_wr_n <= '1';
      state <= S_IDLE;
    elsif rising_edge(nios_clk) then
      case state is
      
        when S_IDLE =>
          coe_uh_cs_n <= '1';   -- default
          coe_uh_rd_n <= '1';   -- default
          coe_uh_wr_n <= '1';   -- default
          coe_uh_d_oe <= '0';   -- default
          if avs_s0_chipselect = '1' then
            if avs_s0_read = '1' then
              coe_uh_cs_n <= '0';
              count := 0;
              state <= S_RD_1;
            elsif avs_s0_write = '1' then
              coe_uh_cs_n <= '0';
              count := 0;
              state <= S_WR_1;
            end if;
          end if;
          
        when S_RD_1 =>
          -- min RDn pulse width (tRPW) is 49.4ns @120MHz, 39.0ns @160MHz
          coe_uh_rd_n <= '0';
          if count < 4 then
            count := count + 1;
          else
            state <= S_RD_2;
          end if;
        when S_RD_2 =>
          -- here is where we read the data
          coe_uh_rd_n <= '1';
          state <= S_RD_3;
        when S_RD_3 =>
          coe_uh_cs_n <= '1';
          state <= S_IDLE;

        when S_WR_1 =>
          -- min WRn pulse width (tWPW) is 12.45ns @120MHz, 9.3ns @160MHz
          coe_uh_wr_n <= '0';
          coe_uh_d_oe <= '1';
          if count < 1 then
            count := count + 1;
          else
						state <= S_WR_2;
          end if;
        when S_WR_2 =>
          -- data setp (tDSW) = 10.9ns @120MHz, 6.7ns @160MHz
          coe_uh_wr_n <= '1';
          state <= S_WR_3;
        when S_WR_3 =>
          coe_uh_cs_n <= '1';
          coe_uh_d_oe <= '0';
          state <= S_IDLE;
          
        when others =>
          state <= S_IDLE;

      end case;
    end if; -- rising_edge(clk)
  end process;

  -- unmeta the interrupt
  process (nios_clk, nios_rst)
    variable int_r  : std_logic_vector(3 downto 0) := (others => '0');
  begin
    if nios_rst = '1' then
      int_r := (others => '0');
    elsif rising_edge(nios_clk) then
      int_r := int_r(int_r'left-1 downto 0) & not coe_uh_int_n;
    end if;
    -- assign output
    avs_s0_irq <= int_r(int_r'left);
  end process;
  
  -- combinatorial logic
  
  coe_uh_reset_n <= not nios_rst;
  coe_uh_a <= avs_s0_address & '0';
  coe_uh_d_i <= coe_uh_d;
  coe_uh_d_o <= avs_s0_writedata;
  coe_uh_d <= coe_uh_d_o when coe_uh_d_oe = '1' else (others => 'Z');
  coe_uh_be <= avs_s0_byteenable;
  coe_uh_dack <= (others => '0');
  
  avs_s0_readdata <= coe_uh_d_i;
  avs_s0_waitrequest <= '0' when (state = S_RD_2 or state = S_WR_3) else '1';
      
end architecture SYN;
		
