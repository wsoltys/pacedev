`include "timescale.v"

`define TB_TOP tb_ocm
module `TB_TOP;

reg fpga_rst;

//
//  CLOCK GENERATION
//

reg     ref_clk;
initial
begin
  ref_clk = 1'b0;
end

  // clock1 - 24MHz
always
  #20.833333 ref_clk = ~ref_clk;

// inputs

// outputs
wire          cpuclk;
wire          reset_n;

wire          ps2clk;
wire          ps2data;
wire [9:0]    red;
wire [9:0]    green;
wire [9:0]    blue;
wire          hsync;
wire          vsync;

assign reset_n = ~fpga_rst;

// Main simulation loop

initial
begin
  // initialise simulation environment
  //$init_signal_spy ("PACE_1/spectrum_inst/u_vid/vsync", "u_vid_vsync");

  // reset processor for a few clocks 
  fpga_rst = 1'b1;
  repeat (30) @(posedge ref_clk);
  fpga_rst = 1'b0;

  // wait a bit

  $stop;

end

emsx_top emsx_1
(
    // Clock, Reset ports
    .pClk21m     (ref_clk),             // VDP clock ... 21.48MHz
    .pExtClk     (ref_clk),             // Reserved (for multi FPGAs)
    .pCpuClk     (cpuclk),         		  // CPU clock ... 3.58MHz (up to 10.74MHz/21.48MHz)
//  pCpuRst_n   : out std_logic;			// CPU reset

    // MSX cartridge slot ports
    .pSltClk     (cpuclk),              // pCpuClk returns here, for Z80, etc.
    .pSltRst_n   (reset_n),             // pCpuRst_n returns here
    .pSltSltsl_n (1'bZ),
    .pSltSlts2_n (1'bZ),
    .pSltIorq_n  (1'bZ),
    .pSltRd_n    (1'bZ),
    .pSltWr_n    (1'bZ),
    .pSltAdr     (16'bZZZZZZZZZZZZZZZZ),
    .pSltDat     (8'bZZZZZZZZ),
    //.pSltBdir_n  : out std_logic;                        // Bus direction (not used in master mode)

    .pSltCs1_n   (1'bz),
    .pSltCs2_n   (1'bZ),
    .pSltCs12_n  (1'bZ),
    .pSltRfsh_n  (1'bZ),
    .pSltWait_n  (1'bZ),
    .pSltInt_n   (1'bZ),
    .pSltM1_n    (1'bZ),
    .pSltMerq_n  (1'bZ),

    //.pSltRsv5    : out std_logic;                        // Reserved
    //.pSltRsv16   : out std_logic;                        // Reserved (w/ external pull-up)
    .pSltSw1     (1'bZ),                // Reserved (w/ external pull-up)
    .pSltSw2     (1'bZ),                // Reserved

    // SD-RAM ports
    //.pMemClk     : out std_logic;                        // SD-RAM Clock
    //.pMemCke     : out std_logic;                        // SD-RAM Clock enable
    //.pMemCs_n    : out std_logic;                        // SD-RAM Chip select
    //.pMemRas_n   : out std_logic;                        // SD-RAM Row/RAS
    //.pMemCas_n   : out std_logic;                        // SD-RAM /CAS
    //.pMemWe_n    : out std_logic;                        // SD-RAM /WE
    //.pMemUdq     : out std_logic;                        // SD-RAM UDQM
    //.pMemLdq     : out std_logic;                        // SD-RAM LDQM
    //.pMemBa1     : out std_logic;                        // SD-RAM Bank select address 1
    //.pMemBa0     : out std_logic;                        // SD-RAM Bank select address 0
    //.pMemAdr     : out std_logic_vector(12 downto 0);    // SD-RAM Address
    //.pMemDat     : inout std_logic_vector(15 downto 0);  // SD-RAM Data

    // PS/2 keyboard ports
    .pPs2Clk     (1'b0),
    .pPs2Dat     (1'b0),

    // Joystick ports (Port_A, Port_B)
    .pJoyA       (6'bZZZZZZ),
    //.pStrA       : out std_logic;
    .pJoyB       (6'bZZZZZZ),
    //.pStrB       : out std_logic;

    // SD/MMC slot ports
    //.pSd_Ck      : out std_logic;                        // pin 5
    //.pSd_Cm      : out std_logic;                        // pin 2
    .pSd_Dt      (4'bZZZZ),                                 // pin 1(D3), 9(D2), 8(D1), 7(D0)

    // DIP switch, Lamp ports
    .pDip        (8'b11111111),                           // 0=ON,  1=OFF(default on shipment)
    //.pLed        : out std_logic_vector( 7 downto 0);    // 0=OFF, 1=ON(green)
    //.pLedPwr     : out std_logic;                        // 0=OFF, 1=ON(red) ...Power & SD/MMC access lamp

    // Video, Audio/CMT ports
    .pDac_VR     (6'bZ),                                  // RGB_Red / Svideo_C
    .pDac_VG     (6'bZ),                                  // RGB_Grn / Svideo_Y
    .pDac_VB     (6'bZ),                                  // RGB_Blu / CompositeVideo
    //.pDac_SL     : out   std_logic_vector( 5 downto 0);  // Sound-L
    //.pDac_SR     : inout std_logic_vector( 5 downto 0);  // Sound-R / CMT

    //.pVideoHS_n  : out std_logic;                        // Csync(RGB15K), HSync(VGA31K)
    //.pVideoVS_n  : out std_logic;                        // Audio(RGB15K), VSync(VGA31K)

    //.pVideoClk   : out std_logic;                        // (Reserved)
    //.pVideoDat   : out std_logic;                        // (Reserved)

    // Reserved ports (USB)
    //.pUsbP1      : inout std_logic;
    //.pUsbN1      : inout std_logic;
    //.pUsbP2      : inout std_logic;
    //.pUsbN2      : inout std_logic;

    // Reserved ports
    .pIopRsv14   (1'b0),
    .pIopRsv15   (1'b0),
    .pIopRsv16   (1'b0),
    .pIopRsv17   (1'b0),
    .pIopRsv18   (1'b0),
    .pIopRsv19   (1'b0),
    .pIopRsv20   (1'b0),
    .pIopRsv21   (1'b0)
);

endmodule
