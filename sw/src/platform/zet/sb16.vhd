library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sound_blaster_16 is
  generic
  (
    IO_BASE_ADDR    : std_logic_vector(15 downto 0) := X"0280";
    DSP_VERSION     : std_logic_vector(15 downto 0) := X"0400"
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

  constant REG_FM_STS           : std_logic_vector(4 downto 0) := '0' & X"0";
  constant REG_FM_REG_ADR       : std_logic_vector(4 downto 0) := REG_FM_STS;
  constant REG_FM_DAT           : std_logic_vector(4 downto 0) := '0' & X"1";
  constant REG_AFM_STS          : std_logic_vector(4 downto 0) := '0' & X"2";
  constant REG_AFM_REG_ADR      : std_logic_vector(4 downto 0) := REG_AFM_STS;
  constant REG_AFM_DAT          : std_logic_vector(4 downto 0) := '0' & X"3";
  constant REG_FM_STS2          : std_logic_vector(4 downto 0) := '0' & X"8";
  constant REG_FM_REG_ADR2      : std_logic_vector(4 downto 0) := REG_FM_STS2;
  constant REG_FM_DAT2          : std_logic_vector(4 downto 0) := '0' & X"9";

  signal dsp_audio_l            : std_logic_vector(15 downto 0) := (others => '0');
  signal dsp_audio_r            : std_logic_vector(15 downto 0) := (others => '0');
  
begin

  -- base address must be $02XX and 32-byte aligned
  assert (IO_BASE_ADDR(15 downto 8) = X"02" and IO_BASE_ADDR(5 downto 0) = "00000")
    report "Unsupported I/O base address"
      severity failure;

  -- 32 bytes of IO address space
  sb16_io_arena <= '1' when wb_adr_i(15 downto 5) = IO_BASE_ADDR(15 downto 5) else '0';
  
  -- register interface - ack immediately
  wb_ack_o <= wb_cyc_i and wb_stb_i;

  -- this will eventually mix all the sound sub-systems
  audio_l <= dsp_audio_l;
  audio_r <= dsp_audio_r;
  
  --
  --  Mixer implementation
  --
  
  BLK_MIXER : block

    constant REG_MXR_ADR          : std_logic_vector(4 downto 0) := '0' & X"4";
    constant REG_MXR_DAT          : std_logic_vector(4 downto 0) := '0' & X"5";

    signal mxr_adr        : std_logic_vector(7 downto 0) := (others => '0');
    
    -- actually, there's only 24 of these
    -- - and the mapping is a bit odd
    -- - registers $30-$3F -> $10-$1F
    -- - registers $40-$47 -> $00-$07
    type mxr_reg_a is array (natural range <>) of std_logic_vector(7 downto 0);
    signal mxr_reg        : mxr_reg_a(0 to 31);
    
  begin

    -- MIXER registers
    process (wb_clk_i, wb_rst_i)
      variable cyc_rd_r : std_logic := '0';
      variable cyc_wr_r : std_logic := '0';
    begin
      if wb_rst_i = '1' then
        mxr_adr <= (others => '0');
        cyc_rd_r := '0';
        cyc_wr_r := '0';
      elsif rising_edge(wb_clk_i) then
        if wb_we_i = '0' then
          -- register READ
          if cyc_rd_r = '0'and wb_cyc_i = '1' and wb_stb_i = '1' then
            case wb_adr_i(4 downto 0) is
              when REG_MXR_DAT =>
                wb_dat_o <= X"00" & mxr_reg(to_integer(unsigned(mxr_adr(4 downto 0))));
              when others =>
                null;
            end case;
          end if;
        else
          -- register WRITE
          if cyc_wr_r = '0' and wb_cyc_i = '1' and wb_stb_i = '1' then
            case wb_adr_i(4 downto 0) is
              when REG_MXR_ADR =>
                mxr_adr <= wb_dat_i(mxr_adr'range);
              when REG_MXR_DAT =>
                case wb_dat_i(7 downto 0) is
                  -- need to handle old addresses here ($00-$2F)!!!
                  when X"04" =>
                    -- Voice Volume L?R
                    mxr_reg(16#12#) <= wb_dat_i(7 downto 4) & "0000";
                    mxr_reg(16#13#) <= wb_dat_i(3 downto 0) & "0000";
                  when X"0A" =>
                    -- Mic Volume
                  when X"22" =>
                    -- Master Volume L/R
                  when X"26" =>
                    -- CD Volume L/R
                  when X"28" =>
                    -- Line Volume L/R
                  when X"2E" =>
                  when others =>
                    mxr_reg(to_integer(unsigned(mxr_adr(4 downto 0)))) <= wb_dat_i(7 downto 0);
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

  end block BLK_MIXER;
  
  --
  --  DSP implementation
  --
  
  BLK_DSP : block

    alias DSP_MAJOR_VER   : std_logic_vector(7 downto 0) is DSP_VERSION(15 downto 8);
    alias DSP_MINOR_VER   : std_logic_vector(7 downto 0) is DSP_VERSION(7 downto 0);
  
    -- DSP registers
    constant REG_DSP_RST          : std_logic_vector(4 downto 0) := '0' & X"6";
    constant REG_DSP_RD_DAT       : std_logic_vector(4 downto 0) := '0' & X"A";
    constant REG_DSP_WR_CMD_DAT   : std_logic_vector(4 downto 0) := '0' & X"C";
    constant REG_DSP_WR_BUF_STS   : std_logic_vector(4 downto 0) := REG_DSP_WR_CMD_DAT;
    constant REG_DSP_RD_BUF_STS   : std_logic_vector(4 downto 0) := '0' & X"E";
    constant REG_DSP_INTACK       : std_logic_vector(4 downto 0) := '0' & X"F";

    -- DSP commands
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
    
    type state_t is 
    ( 
      IDLE, IN_RESET, 
      PRG_8_DIR, 
      GET_DSP_VER,
      DONE 
    );
    signal state            : state_t := IDLE;
    
    signal dsp_rst          : std_logic := '0';
    signal dsp_rd_sts       : std_logic := '0';
    signal set_dsp_rd_sts   : std_logic := '0';
    signal clr_dsp_rd_sts   : std_logic := '0';
    signal dsp_wr_sts       : std_logic := '0';
    signal set_dsp_wr_sts   : std_logic := '0';
    signal clr_dsp_wr_sts   : std_logic := '0';

    signal dsp_rd_dat       : std_logic_vector(wb_dat_o'range) := (others => '0');
    signal dsp_wr_dat       : std_logic_vector(wb_dat_i'range) := (others => '0');
    
  begin
  
    assert (DSP_MAJOR_VER = X"04" and DSP_MINOR_VER = X"00")
      report "Unsupported DSP version specified"
        severity failure;

    -- DSP registers
    process (wb_clk_i, wb_rst_i)
      variable cyc_rd_r : std_logic := '0';
      variable cyc_wr_r : std_logic := '0';
    begin
      if wb_rst_i = '1' then
        dsp_rst <= '0';
        clr_dsp_rd_sts <= '0';
        set_dsp_wr_sts <= '0';
        cyc_rd_r := '0';
        cyc_wr_r := '0';
      elsif rising_edge(wb_clk_i) then
        clr_dsp_rd_sts <= '0';  -- default
        set_dsp_wr_sts <= '0';  -- default
        if wb_we_i = '0' then
          -- register READ
          if cyc_rd_r = '0'and wb_cyc_i = '1' and wb_stb_i = '1' then
            case wb_adr_i(4 downto 0) is
              when REG_DSP_RD_DAT =>
                wb_dat_o <= dsp_rd_dat;
                clr_dsp_rd_sts <= '1';
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
                dsp_wr_dat <= wb_dat_i;
                set_dsp_wr_sts <= '1';
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

    -- DSP RD & WR STATUS RS-flip-flops
    DSP_RD_WR_STS_P : process (wb_clk_i, wb_rst_i)
    begin
      if wb_rst_i = '1' then
        dsp_rd_sts <= '0';
        dsp_wr_sts <= '0';
      elsif rising_edge(wb_clk_i) then
        if set_dsp_rd_sts = '1' then
          dsp_rd_sts <= '1';
        elsif clr_dsp_rd_sts = '1' then
          dsp_rd_sts <= '0';
        end if;
        if set_dsp_wr_sts = '1' then
          dsp_wr_sts <= '1';
        elsif clr_dsp_wr_sts = '1' then
          dsp_wr_sts <= '0';
        end if;
      end if;
    end process DSP_RD_WR_STS_P;
    
    -- DSP STATE MACHINE
    DSP_SM_P : process (wb_clk_i, wb_rst_i)
    begin
      if wb_rst_i = '1' then
        set_dsp_rd_sts <= '0';
      elsif rising_edge(wb_clk_i) then
        set_dsp_rd_sts <= '0';  -- default
        clr_dsp_wr_sts <= '0';  -- default
        if dsp_rst = '1' then
          state <= IN_RESET;
        else
          case state is
            when IDLE =>
              if dsp_wr_sts = '1' then
                case dsp_wr_dat(7 downto 0) is
                  -- 8-bit direct I/O
                  when CMD_PRG_8_DIR =>
                    clr_dsp_wr_sts <= '1';
                    state <= PRG_8_DIR;
                  -- get DSP version
                  when CMD_GET_DSP_VER =>
                    dsp_rd_dat <= X"00" & DSP_MAJOR_VER;
                    set_dsp_rd_sts <= '1';
                    state <= GET_DSP_VER;
                  when others =>
                    state <= DONE;
                end case;
              end if;
            when IN_RESET =>
              if dsp_rst = '0' then
                -- DSP_RD_STS=1, DSP_WR_STS=0
                dsp_rd_dat <= X"AAAA";
                set_dsp_rd_sts <= '1';
                state <= DONE;
              end if;
            when PRG_8_DIR =>
              if dsp_wr_sts = '1' then
                -- parameter is the direct output byte
                state <= DONE;
              end if;
            when GET_DSP_VER =>
              if dsp_rd_sts = '0' then
                dsp_rd_dat <= X"00" & DSP_MINOR_VER;
                set_dsp_rd_sts <= '1';
                state <= DONE;
              end if;
            when others =>
              -- includes DONE state
              clr_dsp_wr_sts <= '1';
              state <= IDLE;
          end case;
        end if;
      end if;
    end process DSP_SM_P;
    
  end block BLK_DSP;
  
end architecture SYN;
