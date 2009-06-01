library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sound_blaster_16 is
  generic
  (
    VERSION         : in std_logic_vector(7 downto 0) := X"10";
    IO_BASE_ADDR    : in std_logic_vector(15 downto 0) := X"0280"
  );
  port
  (
    wb_clk_i        : in std_logic;
    wb_rst_i        : in std_logic;
    wb_adr_i        : in std_logic_vector(15 downto 0);
    wb_dat_i        : in std_logic_vector(15 downto 0);
    wb_dat_o        : out std_logic_vector(15 downto 0);
    wb_sel_i        : in std_logic_vector(1 downto 0);
    wb_cyc_i        : in std_logic;
    wb_stb_i        : in std_logic;
    wb_we_i         : in std_logic;
    wb_ack_o        : out std_logic;
    
    sb16_io_arena   : out std_logic;
    
    audio_l         : out std_logic_vector(15 downto 0);
    audio_r         : out std_logic_vector(15 downto 0)
  );
end entity sound_blaster_16;

architecture SYN of sound_blaster_16 is

  -- registers
  constant REG_FM_STS           : std_logic_vector(4 downto 0) := '0' & X"0";
  constant REG_FM_REG_ADR       : std_logic_vector(4 downto 0) := REG_FM_STS;
  constant REG_FM_DAT           : std_logic_vector(4 downto 0) := '0' & X"1";
  constant REG_AFM_STS          : std_logic_vector(4 downto 0) := '0' & X"2";
  constant REG_AFM_REG_ADR      : std_logic_vector(4 downto 0) := REG_AFM_STS;
  constant REG_AFM_DAT          : std_logic_vector(4 downto 0) := '0' & X"3";
  constant REG_MXR_ADR          : std_logic_vector(4 downto 0) := '0' & X"4";
  constant REG_MXR_DAT          : std_logic_vector(4 downto 0) := '0' & X"5";
  constant REG_DSP_RST          : std_logic_vector(4 downto 0) := '0' & X"6";
  constant REG_FM_STS2          : std_logic_vector(4 downto 0) := '0' & X"8";
  constant REG_FM_REG_ADR2      : std_logic_vector(4 downto 0) := REG_FM_STS2;
  constant REG_FM_DAT2          : std_logic_vector(4 downto 0) := '0' & X"9";
  constant REG_DSP_RD_DAT       : std_logic_vector(4 downto 0) := '0' & X"A";
  constant REG_DSP_WR_CMD_DAT   : std_logic_vector(4 downto 0) := '0' & X"C";
  constant REG_DSP_WR_BUF_STS   : std_logic_vector(4 downto 0) := REG_DSP_WR_CMD_DAT;
  constant REG_DSP_RD_BUF_STS   : std_logic_vector(4 downto 0) := '0' & X"E";
  constant REG_DSP_INTACK       : std_logic_vector(4 downto 0) := '0' & X"F";

  -- commands
  constant CMD_PRG_8_DIR        : std_logic_vector(7 downto 0) := X"10";
  constant CMD_PRG_8_1CYC_DMA   : std_logic_vector(7 downto 0) := X"14";
  constant CMD_PRG_8_AUTO_DMA   : std_logic_vector(7 downto 0) := X"1C";
  constant CMD_SET_TC           : std_logic_vector(7 downto 0) := X"40";
  constant CMD_SET_RATE_HI      : std_logic_vector(7 downto 0) := X"41";
  constant CMD_SET_RATE_LO      : std_logic_vector(7 downto 0) := X"42";
  constant CMD_PRG_16_DMA       : std_logic_vector(7 downto 0) := X"B0";
  constant CMD_PRG_8_DMA        : std_logic_vector(7 downto 0) := X"C0";
  constant CMD_PAUSE_8_DMA      : std_logic_vector(7 downto 0) := X"D0";
  constant CMD_CONT_8_DMA       : std_logic_vector(7 downto 0) := X"D4";
  constant CMD_PAUSE_16_DMA     : std_logic_vector(7 downto 0) := X"D5";
  constant CMD_CONT_16_DMA      : std_logic_vector(7 downto 0) := X"D6";
  constant CMD_EXIT_16_DMA      : std_logic_vector(7 downto 0) := X"D9";
  constant CMD_EXIT_8_DMA       : std_logic_vector(7 downto 0) := X"DA";
  constant CMD_GET_DSP_VER      : std_logic_vector(7 downto 0) := X"E1";
  
begin

  -- 32 bytes of IO address space
  sb16_io_arena <= '1' when wb_adr_i(15 downto 5) = IO_BASE_ADDR(15 downto 5) else '0';
  
  -- register interface - ack immediately
  wb_ack_o <= wb_cyc_i and wb_stb_i;
  
  --
  --  DSP implementation
  --
  
  BLK_DSP : block
  
    signal dsp_rst      : std_logic := '0';
    signal dsp_rd_sts   : std_logic := '0';
    signal dsp_wr_sts   : std_logic := '0';
    signal dsp_rd_dat   : std_logic_vector(15 downto 0) := (others => '0');
    signal dsp_wr_dat   : std_logic_vector(15 downto 0) := (others => '0');
    
  begin
  
    -- DSP registers
    process (wb_clk_i, wb_rst_i)
      variable cyc_rd_r : std_logic := '0';
      variable cyc_wr_r : std_logic := '0';
    begin
      if wb_rst_i = '1' then
        dsp_rst <= '0';
        dsp_wr_sts <= '0';
        cyc_rd_r := '0';
        cyc_wr_r := '0';
      elsif rising_edge(wb_clk_i) then
        if wb_we_i = '0' then
          -- register READ
          if cyc_rd_r = '0'and wb_cyc_i = '1' and wb_stb_i = '1' then
            case wb_adr_i(4 downto 0) is
              when REG_DSP_RD_DAT =>
                wb_dat_o <= dsp_rd_dat;
              when REG_DSP_WR_BUF_STS =>
                wb_dat_o <= X"00" & dsp_wr_sts & "0000000";
              when REG_DSP_RD_BUF_STS =>
                wb_dat_o <= X"00" & dsp_rd_sts & "0000000";
              when REG_DSP_INTACK =>
              when others =>
                null;
            end case;
          end if;
        else
          -- register WRITE
          if cyc_wr_r = '0' and wb_cyc_i = '1' and wb_stb_i = '1' then
            case wb_adr_i(4 downto 0) is
              when REG_DSP_RST =>
                dsp_rst <= wb_dat_i(0);
              when REG_DSP_WR_CMD_DAT =>
                case wb_dat_i(7 downto 0) is
                  when others =>
                end case;
              when others =>
                null;
            end case;
          end if;
        end if;
        -- latch wb cycle type
        cyc_rd_r := wb_cyc_i and wb_stb_i and not wb_we_i;
        cyc_wr_r := wb_cyc_i and wb_stb_i and wb_we_i;
      end if;
    end process;

    -- DSP RESET PROCESS
    DSP_RST_P : process (wb_clk_i, wb_rst_i)
      variable dsp_rst_r : std_logic := '0';
    begin
      if wb_rst_i = '1' then
        dsp_rst_r := '0';
      elsif rising_edge(wb_clk_i) then
        -- DSP reset on falling edge of RST
        if dsp_rst_r = '1' and dsp_rst = '0' then
          dsp_rd_dat <= X"AA";
          dsp_rd_sts <= '1';
          dsp_wr_sts <= '1';
        end if;
        -- latch rst signal value
        dsp_rst_r := dsp_rst;
      end if;
    end process DSP_RST_P;
    
  end block BLK_DSP;
  
end architecture SYN;
