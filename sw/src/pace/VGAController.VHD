library IEEE;
use     IEEE.std_logic_1164.all;

entity VGAController Is
  port
  (
    clk        : in    std_logic;                            
    din        : in    std_logic_vector(7 downto 0);         

    addr_pixel : out   std_logic_vector(18 downto 0);        
    strobe     : out   std_logic;                            
    hblank     : out   std_logic;                            
    vblank     : out   std_logic;                            

    red        : out   std_logic_vector(1 downto 0);         
    green      : out   std_logic_vector(1 downto 0);         
    blue       : out   std_logic_vector(1 downto 0);         
    hsync      : out   std_logic;                            
    vsync      : out   std_logic                             
  );
  attribute MacroCell : boolean;

end VGAController;

architecture SYN of VGAController is

  component VGA                                             
    port
    (
      addr_pixel : out std_logic_vector(18 downto 0);      
      b0         : out std_logic;                          
      b1         : out std_logic;                          
      clk        : in  std_logic;                          
      cmod       : in  std_logic_vector(1 downto 0);       
      data       : in  std_logic_vector(7 downto 0);       
      dispsize_h : in  std_logic_vector(9 downto 0);       
      dispsize_v : in  std_logic_vector(9 downto 0);       
      g0         : out std_logic;                          
      g1         : out std_logic;                          
      hsync      : out std_logic;                          
      r0         : out std_logic;                          
      r1         : out std_logic;                          
      rd         : out std_logic;                          
      resolution : in  std_logic;                          
      rst        : in  std_logic;                          
      vsync      : out std_logic                           
    );
  end component;

  component VGACFG                                          
    port
    (
      mode     : out std_logic_vector(1 downto 0);         
      res      : out std_logic;                            
      vgahsize : out std_logic_vector(9 downto 0);         
      vgavsize : out std_logic_vector(9 downto 0)          
    );
  end component;

  signal rd           : std_logic;
  signal res          : std_logic;
  signal mode         : std_logic_vector (1 downto 0);
  signal vgahsize     : std_logic_vector (9 downto 0);
  signal vgavsize     : std_logic_vector (9 downto 0);
  
begin

  strobe <= rd;
  hblank <= not rd;
  vblank <= not rd;    

  vgacfg_inst  : VGACFG                                        
    port map
    (
      mode     => mode,
      res      => res,
      vgahsize => vgahsize,
      vgavsize => vgavsize
    );

  vga_inst : VGA                                              
    port map
    (
      clk        => clk,
      rst        => '0',

      resolution => res,
      cmod       => mode,
      dispsize_h => vgahsize,
      dispsize_v => vgavsize,

      rd         => rd,
      data       => din,
      addr_pixel => addr_pixel,

      hsync      => hsync,
      vsync      => vsync,
      r0         => red(0),
      r1         => red(1),
      g0         => green(0),
      g1         => green(1),
      b0         => blue(0),
      b1         => blue(1)
    );

end SYN;

