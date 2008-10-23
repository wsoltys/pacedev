library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

entity osd_controller is
  generic
  (
    WIDTH_GPIO  : natural := 8
  );
  port
  (
    clk         : in std_logic;
    clk_en      : in std_logic;
    reset       : in std_logic;

    osd_key     : in std_logic;

    to_osd      : out to_OSD_t;
    from_osd    : in from_OSD_t;

    gpio_i      : in std_logic_vector(WIDTH_GPIO-1 downto 0);
    gpio_o      : out std_logic_vector(WIDTH_GPIO-1 downto 0);
    gpio_oe     : out std_logic_vector(WIDTH_GPIO-1 downto 0)
  );
end entity osd_controller;

architecture SYN of osd_controller is

  signal cpu_a_u    : unsigned(15 downto 0);
  signal cpu_d_o_u  : unsigned(7 downto 0);

  signal cpu_clk_en : std_logic;
  signal cpu_a      : std_logic_vector(15 downto 0);
  signal cpu_d_i    : std_logic_vector(7 downto 0);
  signal cpu_d_o    : std_logic_vector(7 downto 0);
  signal cpu_we     : std_logic;

  signal ram_cs     : std_logic;
  signal ram_we     : std_logic;
  signal ram_d      : std_logic_vector(7 downto 0);

  signal gpio_cs    : std_logic;
  signal gpio_d     : std_logic_vector(7 downto 0);

  signal osd_cs     : std_logic;

  signal vec_cs     : std_logic;

  signal osd_en_s   : std_logic;

begin

  -- osd toggle (TAB)
  process (clk, reset)
    variable osd_key_r  : std_logic;
  begin
    if reset = '1' then
      osd_en_s <= '0';
      osd_key_r := '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        -- toggle on OSD KEY PRESS
        if osd_key = '1' and osd_key_r = '0' then
          osd_en_s <= not osd_en_s;
        end if;
        osd_key_r := osd_key;
      end if;
    end if;
    -- assign outputs
    to_osd.en <= osd_en_s;
  end process;

  -- produce a slower cpu clock
  process (clk)
    subtype count_t is integer range 0 to 3;
    variable count  : count_t;
  begin
    -- can't use reset as cpu needs to be clocked during reset
    if rising_edge(clk) then
      cpu_clk_en <= '0';
      if count = count_t'high then
        cpu_clk_en <= '1';
        count := 0;
      else
        count := count + 1;
      end if;
    end if;
  end process;

  -- address decoding
  -- ROM/RAM $0000-$7FFF (32K)
  ram_cs <= '1'   when STD_MATCH(cpu_a, "0---------------") else '0';
  -- GPIO $E000-$E0FF
  gpio_cs <= '1'  when STD_MATCH(cpu_a, X"E0" & "--------") else '0';
  -- OSD screen buffer $E100-$E1FF (256 bytes)
  osd_cs <= '1'   when STD_MATCH(cpu_a, X"E1" & "--------") else '0';
  -- reset vectors $FFF0-$FFFF (16 bytes)
  vec_cs <= '1'   when STD_MATCH(cpu_a,    X"FFF" & "----") else '0';

  -- write enables
  ram_we <= ram_cs and cpu_we;

  -- gpio read mux
  gpio_d <= osd_en_s & "0000000" when cpu_a(0) = '0' else
            gpio_i;

  -- read mux
  cpu_d_i <=  ram_d when ram_cs = '1' else
              gpio_d when gpio_cs = '1' else
              (from_osd.d + 32) when osd_cs = '1' else
              X"08" when (vec_cs = '1' and cpu_a(0) = '1') else
              X"00" when (vec_cs = '1' and cpu_a(0) = '0') else
              (others => '1');

  -- hook up OSD screen buffer bus
  to_osd.a <= cpu_a(to_osd.a'range);
  to_osd.d <= cpu_d_o - 32;
  to_osd.we <= osd_cs and cpu_we;

  cpu_inst : entity work.cpu65xx
    generic map
    (
      pipelineOpcode  => false,
      pipelineAluMux  => false,
      pipelineAluOut  => false
    )
    port map
    (
      clk             => clk,
      enable          => cpu_clk_en,
      reset           => reset,
      nmi_n           => '1',
      irq_n           => '1',
      so_n            => '1',

      di              => unsigned(cpu_d_i),
      do              => cpu_d_o_u,
      addr            => cpu_a_u,
      we              => cpu_we
    );

    cpu_d_o <= std_logic_vector(cpu_d_o_u);
    cpu_a <= std_logic_vector(cpu_a_u);

  -- memory is accessible via Altera's In-System Memory Conent Editor
  cpuram_inst : entity work.osd_mem
    port map
    (
      clock		    => clk,
      address		  => cpu_a(14 downto 0),
      data		    => cpu_d_o,
      q		        => ram_d,
      wren		    => ram_we
    );

end SYN;
