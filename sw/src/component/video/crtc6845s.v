//--------------------------------------------------------------------------------------
// CRTC6845(HD46505) CORE 
//
// Version : beta 1
//
// Copyright(c) 2004 Katsumi Degawa , All rights reserved.
//
// Important !
//
// This program is freeware for non-commercial use. 
// An author does no guarantee about this program.
// You can use this under your own risk. 
//
// VerilogHDL model of MC6845(HD46505) compatible CRTC.
// This was made for FPGA-GAME(ROCK-OLA). 
// Therefore. There is a limitation in the function. 
// 1. This doesn't implement interlace mode.
// 2. This doesn't implement light pen detection founction.
// 3. This doesn't implement cursor control founction.
//
// File History
//  2004.10.23  First release  
//--------------------------------------------------------------------------------------


module crtc6845s(
// INPUT
I_E,
I_DI,
I_RS,
I_RWn,
I_CSn,
I_CLK,
I_RSTn,

// OUTPUT
O_RA,
O_MA,
O_H_SYNC,
O_V_SYNC,
O_DISPTMG

);

input  I_E;
input  [7:0]I_DI;
input  I_RS;
input  I_RWn;
input  I_CSn;

input  I_CLK;
input  I_RSTn;

output [4:0]O_RA;
output [13:0]O_MA;
output O_H_SYNC;
output O_V_SYNC;
output O_DISPTMG;

wire   [7:0]W_Nht;
wire   [7:0]W_Nhd;
wire   [7:0]W_Nhsp;
wire   [3:0]W_Nhsw;
wire   [7:0]W_Nvt;
wire   [4:0]W_Nadj;
wire   [7:0]W_Nvd;
wire   [7:0]W_Nvsp;
wire   [3:0]W_Nvsw;
wire   [5:0]W_Nr;
wire   [13:0]W_Msa;

mpu_if mpu_if(

.I_E(I_E),
.I_DI(I_DI),
.I_RS(I_RS),
.I_RWn(I_RWn),
.I_CSn(I_CSn),

.O_Nht(W_Nht),
.O_Nhd(W_Nhd),
.O_Nhsp(W_Nhsp),
.O_Nhsw(W_Nhsw),
.O_Nvt(W_Nvt),
.O_Nadj(W_Nadj),
.O_Nvd(W_Nvd),
.O_Nvsp(W_Nvsp),
.O_Nvsw(W_Nvsw),
.O_Nr(W_Nr),
.O_Msa(W_Msa)

);

crtc_gen crtc_gen(

.I_CLK(I_CLK),
.I_RSTn(I_RSTn),
.I_Nht(W_Nht),
.I_Nhd(W_Nhd),
.I_Nhsp(W_Nhsp),
.I_Nhsw(W_Nhsw),
.I_Nvt(W_Nvt),
.I_Nadj(W_Nadj),
.I_Nvd(W_Nvd),
.I_Nvsp(W_Nvsp),
.I_Nvsw(W_Nvsw),
.I_Nr(W_Nr),
.I_Msa(W_Msa),

.O_RA(O_RA),
.O_MA(O_MA),
.O_H_SYNC(O_H_SYNC),
.O_V_SYNC(O_V_SYNC),
.O_DISPTMG(O_DISPTMG)

);


endmodule


module mpu_if(

I_E,
I_DI,
I_RS,
I_RWn,
I_CSn,

O_Nht,
O_Nhd,
O_Nhsp,
O_Nhsw,
O_Nvt,
O_Nadj,
O_Nvd,
O_Nvsp,
O_Nvsw,
O_Nr,
O_Msa

);

input  I_E;
input  [7:0]I_DI;
input  I_RS;
input  I_RWn;
input  I_CSn;

output [7:0]O_Nht;
output [7:0]O_Nhd;
output [7:0]O_Nhsp;
output [3:0]O_Nhsw;
output [7:0]O_Nvt;
output [4:0]O_Nadj;
output [7:0]O_Nvd;
output [7:0]O_Nvsp;
output [3:0]O_Nvsw;
output [5:0]O_Nr;
output [13:0]O_Msa;

reg    [3:0]R_ADR;
reg    [7:0]R_Nht;
reg    [7:0]R_Nhd;
reg    [7:0]R_Nhsp;
reg    [7:0]R_Nsw;
reg    [7:0]R_Nvt;
reg    [7:0]R_Nadj;
reg    [7:0]R_Nvd;
reg    [7:0]R_Nvsp;
reg    [7:0]R_Nr;
reg    [7:0]R_Msah;
reg    [7:0]R_Msal;

assign O_Nht  = R_Nht;
assign O_Nhd  = R_Nhd;
assign O_Nhsp = R_Nhsp;
assign O_Nhsw = R_Nsw[3:0];
assign O_Nvt  = R_Nvt;
assign O_Nadj = R_Nadj[4:0];
assign O_Nvd  = R_Nvd;
assign O_Nvsp = R_Nvsp;
assign O_Nvsw = R_Nsw[7:4];
assign O_Nr   = R_Nr[4:0];
assign O_Msa  = {R_Msah[5:0],R_Msal[7:0]};

always@(negedge I_E)
begin
  if(~I_CSn)begin
    if(~I_RWn)begin
      if(~I_RS)begin      
        R_ADR <= I_DI[3:0];
      end else begin
        case(R_ADR)
          4'h0 : R_Nht  <= I_DI ;
          4'h1 : R_Nhd  <= I_DI ;
          4'h2 : R_Nhsp <= I_DI ;
          4'h3 : R_Nsw  <= I_DI ;
          4'h4 : R_Nvt  <= I_DI ;
          4'h5 : R_Nadj <= I_DI ;
          4'h6 : R_Nvd  <= I_DI ;
          4'h7 : R_Nvsp <= I_DI ;
          4'h9 : R_Nr   <= I_DI ;
          4'hC : R_Msah <= I_DI ;
          4'hD : R_Msal <= I_DI ;
          default:;
        endcase
      end
    end
  end
end


endmodule


module crtc_gen(

I_CLK,
I_RSTn,
I_Nht,
I_Nhd,
I_Nhsp,
I_Nhsw,
I_Nvt,
I_Nadj,
I_Nvd,
I_Nvsp,
I_Nvsw,
I_Nr,
I_Msa,

O_RA,
O_MA,
O_H_SYNC,
O_V_SYNC,
O_DISPTMG

);

input  I_CLK;
input  I_RSTn;
input  [7:0]I_Nht;
input  [7:0]I_Nhd;
input  [7:0]I_Nhsp;
input  [3:0]I_Nhsw;
input  [7:0]I_Nvt;
input  [4:0]I_Nr;
input  [4:0]I_Nadj;  //  (I_Nadj-1 <= I_Nr) is Support. (I_Nadj-1 > I_Nr) is Not Support.
input  [7:0]I_Nvd;
input  [7:0]I_Nvsp;
input  [3:0]I_Nvsw;
input  [13:0]I_Msa;

output [4:0]O_RA;
output [13:0]O_MA;
output O_H_SYNC;
output O_V_SYNC;
output O_DISPTMG;

reg    [7:0]R_H_CNT;
reg    [8:0]R_V_CNT;
reg    [4:0]R_RA;
reg    [13:0]R_MA;
reg    R_H_SYNC,R_V_SYNC;
reg    R_H_DISPTMG,R_V_DISPTMG0,R_V_DISPTMG1;

wire   [7:0]W_HSYNC_P = I_Nhsp - 8'h01 ;
wire   [7:0]W_HSYNC_W = I_Nhsp + {4'h0,I_Nhsw} - 8'h01 ;
wire   [8:0]W_VSYNC_P = {1'b0,I_Nvsp} - 9'h001 ;
wire   [8:0]W_VSYNC_W = {1'b0,I_Nvsp} + {5'h0,I_Nvsw};

wire   W_HD   = (R_H_CNT==I_Nht)? 1'b1:1'b0;
wire   W_ADJ  = (I_Nadj==0)? 1'b0: 1'b1;
wire   [8:0]W_V_MAX = {1'b0,I_Nvt} + {8'h00,W_ADJ} ;
wire   W_RA_C = (W_ADJ&(R_V_CNT==W_V_MAX)&(R_RA==I_Nadj-1)&W_HD)? 1'b1:((R_RA==I_Nr)&W_HD)? 1'b1: 1'b0;

assign O_H_SYNC = R_H_SYNC;
assign O_V_SYNC = R_V_SYNC;
assign O_RA     = R_RA;
assign O_MA     = R_MA + I_Msa;
assign O_DISPTMG = I_RSTn ? R_H_DISPTMG & R_V_DISPTMG0 & R_V_DISPTMG1: 1'b0;

//  MA   MAX = 14'h3FFF  ---------------------
reg    [13:0]R_MA_C;
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn)begin
    R_MA   <= 14'h0000;
    R_MA_C <= 14'h0000;
  end
  else begin
    if(R_V_CNT==W_V_MAX)begin
      if(W_ADJ)begin
        if(R_RA==I_Nadj-1)
          R_MA_C <= 14'h0000;
      end
      else begin
        if(R_RA==I_Nr)
          R_MA_C <= 14'h0000;
      end
    end
    else begin
      if(R_RA==I_Nr)begin
        if(R_H_CNT==I_Nhd)
          R_MA_C <= R_MA ;
      end
    end
    if(R_H_CNT >= I_Nht)
      R_MA <= R_MA_C;
    else
      R_MA <= R_MA + 1;
  end
end

//  H COUNT  MAX = 8'hFF  --------------------
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn) R_H_CNT <= 8'h00; 
  else begin
    if(R_H_CNT >= I_Nht)
      R_H_CNT <= 8'h00; 
    else
      R_H_CNT <= R_H_CNT +1;
  end
end

//  H SYNC  ----------------------------------
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn) R_H_SYNC <= 0; 
  else begin
    case(R_H_CNT)
      W_HSYNC_P: R_H_SYNC <= 1;
      W_HSYNC_W: R_H_SYNC <= 0;
      default  :;
    endcase
  end
end

//  RA  MAX = 8'h1F  ------------------------
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn) R_RA <= 5'h00; 
  else begin
    if(W_HD)begin
      if(W_ADJ&(R_V_CNT==W_V_MAX))begin
        if(R_RA >= I_Nadj-1)
          R_RA <= 5'h00; 
        else
          R_RA <= R_RA + 1;
      end
      else begin 
        if(R_RA >= I_Nr)
          R_RA <= 5'h00; 
        else
          R_RA <= R_RA + 1;
      end
    end
  end
end

//  V COUNT  MAX = 8'hFF  --------------------
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn) R_V_CNT <= 8'h00; 
  else begin
    if(W_RA_C)begin
      if(R_V_CNT >= W_V_MAX)
        R_V_CNT <= 8'h00; 
      else
        R_V_CNT <= R_V_CNT +1;
    end
  end
end

//  V SYNC  ----------------------------------
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn) R_V_SYNC <= 0; 
  else begin
    if(W_RA_C)begin
      case(R_V_CNT)
        W_VSYNC_P: R_V_SYNC <= 1;
        W_VSYNC_W: R_V_SYNC <= 0;
        default  :;
      endcase
    end
  end
end

//  DISPTMG  ---------------------------------
always@(negedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn)begin
    R_H_DISPTMG <= 1;
    R_V_DISPTMG0 <= 1;
  end 
  else begin
    case(R_H_CNT)
      I_Nht  : R_H_DISPTMG <= 1;
      I_Nhd-1: R_H_DISPTMG <= 0;
      default:;
    endcase
    if(W_RA_C)begin
      case(R_V_CNT)
        W_V_MAX: R_V_DISPTMG0 <= 1;
        I_Nvd-1: R_V_DISPTMG0 <= 0;
        default:;
      endcase
    end
  end
end
always@(posedge I_CLK or negedge I_RSTn)
begin
  if(! I_RSTn) R_V_DISPTMG1 <= 1;
  else begin
    if(W_RA_C)begin
      case(R_V_CNT)
        W_V_MAX: R_V_DISPTMG1 <= 1;
        I_Nvd-1: R_V_DISPTMG1 <= 0;
        default:;
      endcase
    end
  end
end


endmodule

