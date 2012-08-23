#ifndef __OXU210HP_H__
#define __OXU210HP_H__

#include <io.h>
#include <system.h>

// Register Bank Base Addresses

#define HOSTIF_BASE                   (OXU210HP_IF_0_BASE + 0x0000)
#define OTG_BASE                      (OXU210HP_IF_0_BASE + 0x0400)
#define SPH_BASE                      (OXU210HP_IF_0_BASE + 0x0800)
#define MEM_BASE                      (OXU210HP_IF_0_BASE + 0xE000)
                                      
#define HOSTIF_REG(r)                 (HOSTIF_BASE+(r))
#define OTG_REG(r)                    (OTG_BASE+(r))
#define SPH_REG(r)                    (SPH_BASE+(r))
#define USB_MEM(a)                    (MEM_BASE+(a))
                                      
//                                      
// HOSTIF Registers                   
//                                    
                                      
#define R_DeviceID                    0x0000
#define R_HostIfConfig                0x0004
#define R_SoftReset                   0x0008
#define R_BurstReadCtrl               0x000C
#define R_ChipIRQStatus               0x0010
#define R_ChipIRQEn_Set               0x0014
#define R_ChipIRQEn_Clr               0x0018
#define R_ClkCtrl_Set                 0x001C
#define R_ClkCtrl_Clr                 0x0020
#define R_ClkFreq                     0x0024
#define R_Scratch_RW                  0x0028
#define R_Scratch_Set                 0x002C
#define R_Scratch_Clr                 0x0030
#define R_GPIODataOut                 0x0040
#define R_GPIODataOE                  0x0044
#define R_GPIODataIn                  0x0048
#define R_GPIO_IRQStatus              0x004C
#define R_GPIO_IRQEn                  0x0050
#define R_GPIO_IRQSense               0x0054
#define R_GPIO_IRQEdgeLevel           0x0058
#define R_GPIO_IRQOnChange            0x005C
#define R_GPIO_PUEN                   0x0060
#define R_GPIO_PDEN                   0x0064
#define R_ASO                         0x0068
#define R_IO_Control                  0x006C
#define R_PwrWakeUpOTG                0x0070
#define R_PwrWakeUpSPH                0x0074
#define R_SDMA_IFConfig               0x0100
#define R_SDMA_AckTimeOut             0x0104
#define R_SDMABurstReadCtrl           0x0108
#define R_SDMAXferCount0              0x010C
#define R_SDMAXferCount1              0x0124
#define R_SDMAIRQStatus0              0x0110
#define R_SDMAIRQStatus1              0x0128
#define R_SDMA_IRQEn_SET0             0x0114
#define R_SDMA_IRQEn_SET1             0x012C
#define R_SDMA_IRQEn_Clr0             0x0118
#define R_SDMA_IRQEn_Clr1             0x0130
#define R_SDMAStartAddr0              0x011C
#define R_SDMAStartAddr1              0x0134
#define R_SDMAEndAddr0                0x0120
#define R_SDMAEndAddr1                0x0138
#define R_MailboxDataRead0            0x0200
#define R_MailboxDataRead(n)          (R_MailboxDataRead0+((n)*0x0C))
#define R_MailboxDataWrite0           0x0204
#define R_MailboxDataWrite(n)         (R_MailboxDataWrite0+((n)*0x0C))
#define R_MailBoxControl0             0x0208
#define R_MailBoxControl(n)           (R_MailboxControl0+((n)*0x0C))
                                      
// R_HostIfConfig                     
#define HostIfConfig_V                (1<<15)
#define HostIfConfig_ME               (1<<11)
#define HostIfConfig_B                (1<<10)
#define HostIfConfig_X                (1<<9)
#define HostIfConfig_Y                (1<<8)
#define HostIfConfig_BE               (1<<7)
#define HostIfConfig_BP               (1<<6)
#define HostIfConfig_AP               (1<<5)
#define HostIfConfig_RP               (1<<4)
#define HostIfConfig_DT               (1<<3)
#define HostIfConfig_IP               (1<<2)
#define HostIfConfig_BM               (1<<0)
                                      
// R_ChipIRQEn_Set                    
#define ChipIRQEn_SW                  (1<<7)
#define ChipIRQEn_OW                  (1<<6)
#define ChipIRQEn_E1                  (1<<5)
#define ChipIRQEn_E0                  (1<<4)
#define ChipIRQEn_GE                  (1<<3)
#define ChipIRQEn_SE                  (1<<1)
#define ChipIRQEn_OE                  (1<<0)

// R_ClkCtrl
#define R_ClkCtrl_CE                  (1<<3)
#define R_ClkCtrl_SE                  (1<<1)
#define R_ClkCtrl_OE                  (1<<0)

// R_PwrWakeUpSPH                     
#define PwrWakeUpSPH_V                (1<<4)
#define PwrWakeUpSPH_O                (1<<3)
#define PwrWakeUpSPH_K                (1<<2)
#define PwrWakeUpSPH_J                (1<<1)
#define PwrWakeUpSPH_L0               (1<<0)
                                      
//                                      
// OTG/SPH Registers                  
//                                    
                                      
#define R_ID                          0x0000
#define R_HWGeneral                   0x0004
#define R_HWHost                      0x0008
#define R_HWPeriph                    0x000C
#define R_HWTXBuf                     0x0010
#define R_HWRXBuf                     0x0014
#define R_CapLength                   0x0100
#define R_HCIVersion                  0x0102
#define R_HCSParams                   0x0104
#define R_HCCParams                   0x0108
#define R_DCIVersion                  0x0120
#define R_DCCParams                   0x0124
#define R_GPTimer0LD                  0x0080
#define R_GPTimer0CTRL                0x0084
#define R_GPTimer1LD                  0x0088
#define R_GPTimer1CTRL                0x008C
#define R_USBCmd                      0x0140
#define R_USBSts                      0x0144
#define R_USBIntr                     0x0148
#define R_FRIndex                     0x014C
#define R_PeriodicListBase            0x0154
#define R_DeviceAddr                  (R_PeriodicListBase)
#define R_AsyncListAddr               0x0158
#define R_EndPointListAddr            (R_AsyncListAddr)
#define R_TTCtrl                      0x015C
#define R_BurstSize                   0x0160
#define R_TXFillTuning                0x0164
#define R_EndPtNAK                    0x0178
#define R_EndPtNAK_En                 0x017C
#define R_PortSCx                     0x0184
#define R_OTGSC                       0x01A4
#define R_USBMode                     0x01A8
#define R_EndPtSetupStat              0x01AC
#define R_EndPtPrime                  0x01B0
#define R_EndPtFlush                  0x01B4
#define R_EndPtStat                   0x01B8
#define R_EndPtComplete               0x01BC
#define R_EndPtCtrl0                  0x01C0
#define R_EndPtCtrl(n)                (R_EndPtCtrl0+(n<<2))
                                
// R_USBCmd                     
#define USBCmd_AT                     (1<<14)
#define USBCmd_ST                     (1<<13)
#define USBCmd_ME                     (1<<11)
#define USBCmd_IA                     (1<<6)
#define USBCmd_AE                     (1<<5)
#define USBCmd_PE                     (1<<4)
#define USBCmd_CR                     (1<<1)
#define USBCmd_RS                     (1<<0)
                                
// R_USBSts / R_USBIntr            
#define USBSts_T1                     (1<<25)
#define USBSts_T0                     (1<<24)
#define USBSts_HP                     (1<<19)
#define USBSts_HA                     (1<<18)
#define USBSts_NK                     (1<<16)
#define USBSts_AS                     (1<<15)
#define USBSts_PS                     (1<<14)
#define USBSts_RC                     (1<<13)
#define USBSts_HC                     (1<<12)
#define USBSts_UI                     (1<<10)
#define USBSts_SU                     (1<<8)
#define USBSts_SF                     (1<<7)
#define USBSts_UR                     (1<<6)
#define USBSts_AI                     (1<<5)
#define USBSts_SE                     (1<<4)
#define USBSts_FL                     (1<<3)
#define USBSts_PC                     (1<<2)
#define USBSts_EI                     (1<<1)
#define USBSts_I                      (1<<0)

// R_PortSCx
#define PortSCx_S_FullSpeed           (0x0<<26)
#define PortSCx_S_LowSpeed            (0x1<<26)
#define PortSCx_S_HighSpeed           (0x2<<26)
#define PortSCx_F                     (1<<24)
#define PortSCx_LP                    (1<<23)
#define PortSCx_WO                    (1<<22)
#define PortSCx_WD                    (1<<21)
#define PortSCx_WC                    (1<<20)
#define PortSCx_PTC_TestModeDisable   (0x0<<16)
#define PortSCx_PTC_JState            (0x1<<16)
#define PortSCx_PTC_KState            (0x2<<16)
#define PortSCx_PTC_SE0_NAK           (0x3<<16)
#define PortSCx_PTC_Packet            (0x4<<16)
#define PortSCx_PTC_ForceEnableHS     (0x5<<16)
#define PortSCx_PTC_ForceEnableFS     (0x6<<16)
#define PortSCx_PTC_ForceEnableLS     (0x7<<16)
#define PortSCx_PIC_Off               (0x0<<14)
#define PortSCx_PIC_Amber             (0x1<<14)
#define PortSCx_PIC_Green             (0x2<<14)
#define PortSCx_PIC_Undefined         (0x3<<14)
#define PortSCx_PP                    (1<<12)
#define PortSCx_LS_SE0                (0x0<<10)
#define PortSCx_LS_JState             (0x1<<10)
#define PortSCx_LS_KState             (0x2<<10)
#define PortSCx_LS_Undefined          (0x3<<10)
#define PortSCx_H                     (1<<9)
#define PortSCx_R                     (1<<8)
#define PortSCx_S                     (1<<7)
#define PortSCx_FR                    (1<<6)
#define PortSCx_OC                    (1<<5)
#define PortSCx_OA                    (1<<4)
#define PortSCx_PC                    (1<<3)
#define PortSCx_PE                    (1<<2)
#define PortSCx_SC                    (1<<1)
#define PortSCx_CS                    (1<<0)
                                      
// R_USBMode                          
#define USBMode_VB                    (1<<5)
#define USBMode_SD                    (1<<4)
#define USBMode_SL                    (1<<3)
#define USBMode_ES                    (1<<2)
#define USBMode_CM_Idle               0x0
#define USBMode_CM_Reserved           0x1
#define USBMode_CM_Peripheral         0x2
#define USBMode_CM_Host               0x3


typedef uint32_t FrameListLinkPtr, *PFrameListLinkPtr;
#define TYP_ISOCHRONOUS_TRANSFER_DESCR    0x0
#define TYP_QUEUE_HEAD                    0x1
#define TYP_SPLIT_TRANSACTION_ISO         0x2
#define TYP_FRAME_SPAN_TRAVERSAL_NODE     0x3

typedef struct
{
  uint32_t NextqTDPtr;
  uint32_t AltNextqTDPtr;
  uint32_t TransferState;
  uint32_t BufferPtr[5];
  
} qTD, *PqTD;

typedef struct
{
  uint32_t HorizontalLinkPtr;
  uint32_t StaticEndPointState[2];
  uint32_t CurrentqTDPtr;
  qTD     TransferOverlay;
    
} qHead, *PqHead;

#define OXU210HP_RD(r)            IORD_32DIRECT(OXU210HP_IF_0_BASE, (r))
#define OXU210HP_WR(r,d)          IOWR_32DIRECT(OXU210HP_IF_0_BASE, (r), (d))

#define OXU210HP_HOSTIF_RD(r)     OXU210HP_RD(HOSTIF_REG(r))
#define OXU210HP_HOSTIF_WR(r,d)   OXU210HP_WR(HOSTIF_REG(r), (d))

#define OXU210HP_OTG_RD(r)        OXU210HP_RD(OTG_REG(r))
#define OXU210HP_OTG_WR(r,d)      OXU210HP_WR(OTG_REG(r), (d))

#define OXU210HP_MEM_RD(a)        IORD_32DIRECT(OXU210HP_IF_0_BASE, USB_MEM(a))
#define OXU210HP_MEM_WR(a,d)      IOWR_32DIRECT(OXU210HP_IF_0_BASE, USB_MEM(a), (d))

#endif
