#ifndef __VEB_H__
#define __VEB_H__

//
// build options
//

//#define HARDWARE_REVISION						"A0"
//#define PCB_COLOUR                  0xA0191E
//#define HARDWARE_REVISION						"B0"
//#define PCB_COLOUR                  0x122D64
#define HARDWARE_REVISION						"C0"
//#define PCB_COLOUR                  0xA0191E
#define PCB_COLOUR                  0x006600

//#define HARDWARE_VARIANT            "Sentinel 5"
//#define HARDWARE_VARIANT            "Sentinel-Lite"
#define HARDWARE_VARIANT            "PACE"

#define SOFTWARE_VERSION            ((VER_MINOR << 8) | VER_REVISION)

// this should be ON for production builds

#define BUILD_MINIMAL
#define BUILD_QUARTUS_V10

// these may or may not be on
#define BUILD_ENABLE_ANALOGUE
#define BUILD_ENABLE_USB
#define BUILD_ENABLE_SYNCHRONISERS
#define BUILD_HAS_VFB_CONTROL_PORTS
#define ANIMATE_IN_ISR

#ifdef BUILD_ENABLE_SYNCHRONISERS
  #define BUILD_USE_SYNC_CLIPPER
  #define BUILD_USE_SYNC_SCALER
  #define BUILD_USE_SYNC_MIXER
  #define BUILD_USE_SYNC_ALPHA
#endif

// USB peripheral support
//#define BUILD_PERIPH_3M_MTOUCH_RAW
//#define BUILD_PERIPH_3M_MTOUCH_HID
#define BUILD_PERIPH_ZYTRONIC
//#define BUILD_PERIPH_HIDJOY

//
// all of these should be OFF for production builds
//

//#define BUILD_DISABLE_VIP_CORE
//#define BUILD_DONT_WAIT_FOR_START_STOP
//#define BUILD_DISABLE_SERIAL_TS
//#define BUILD_DISABLE_TS_CORRECTION
//#define BUILD_FORCE_OUTPUT_MODE		0

//
// derived - do not edit
//

#ifdef BUILD_ENABLE_USB
	#define BUILD_TS_USB
#else
	#ifndef BUILD_DISABLE_SERIAL_TS
		#define BUILD_TS_SERIAL
	#endif
#endif

#ifndef BUILD_MINIMAL
// include debug code
#define BUILD_INCLUDE_DEBUG
// show the sentinel on top, opaque
#define DEFAULT_SHOW_SENTINEL
//#define DEFAULT_SENTINEL_ONLY
//#define SDVO_EDID_HACK
//#define DISABLE_ULYANA
// VCB is the MCE video converter box
//#define BUILD_IS_VCB
#endif

//
// hardware definitions
//

//
//  EP3SL
//

// DDR full rate clock (Hz) >> 13
//#define FAST_CLOCK_RATE (384020000L >> 13L)
#define FAST_CLOCK_RATE (360000000L >> 13L)

#define VIP_EGMVID_IN_EP3SL_BASE 				  			(0x00000000)
#define VIP_EGMVID_CLIP_EP3SL_BASE 			        (0x00000500)
#define VIP_EGMVID_SCL_EP3SL_BASE 				      (0x00000600)
#define VIP_EGMVID_VFB_EP3SL_BASE               (0x00000800)
#define VIP_EGMVID_ALPHA_EP3SL_BASE 						(0x00001000)
#define VIP_S5VID_IN_EP3SL_BASE 			          (0x00002000)
#define VIP_S5VID_CLIP_EP3SL_BASE 			        (0x00002500)
#define VIP_S5VID_SCL_EP3SL_BASE 				        (0x00002600)
#define VIP_S5VID_VFB_EP3SL_BASE                (0x00002800)
#define VIP_S5VID_ALPHA_EP3SL_BASE 						  (0x00003000)
#define VIP_TILEMAP_REGS_EP3SL_BASE    					(0x00004700)
#define VIP_TILEMAP_ALPHA_TPG_EP3SL_BASE 			  (0x00004800)
#define VIP_OUTVID_MIXER_EP3SL_BASE 				  	(0x00005000)
#define VIP_OUTVID_OUT_EP3SL_BASE 				      (0x00006000)
#define VIP_EGMVID_SYNC_MASTER_EP3SL_BASE				(0x00010000)
#define VIP_EGMVID_SYNC_SLAVE_EP3SL_BASE				(0x00010400)
#define VIP_S5VID_SYNC_MASTER_EP3SL_BASE				(0x00012000)
#define VIP_S5VID_SYNC_SLAVE_EP3SL_BASE					(0x00012400)
#define VIP_TILEMAP_MEM_EP3SL_BASE     					(0x00020000)
#define BRIDGE_PERIPHERALS_BASE(a)              (0x00040000+a)
#define PIO_EGMVID_EP3SL_BASE 					        BRIDGE_PERIPHERALS_BASE(0x0000)
#define PIO_EGMVID_SEL_EP3SL_BASE 				      BRIDGE_PERIPHERALS_BASE(0x0080)
#define PIO_S5VID_EP3SL_BASE 				          	BRIDGE_PERIPHERALS_BASE(0x0100)
#define PIO_OUTVID_EP3SL_BASE               		BRIDGE_PERIPHERALS_BASE(0x0180)
#define PIO_VERSION_EP3SL_BASE 				          BRIDGE_PERIPHERALS_BASE(0x0200)
#define PIO_DVI_CLK_EP3SL_BASE 				          BRIDGE_PERIPHERALS_BASE(0x0280)
#define PIO_DVO_CLK_EP3SL_BASE 				          BRIDGE_PERIPHERALS_BASE(0x0300)
#define PIO_SDVO_CLK_EP3SL_BASE 				        BRIDGE_PERIPHERALS_BASE(0x0380)
#define PIO_BASE_CLK_EP3SL_BASE 			          BRIDGE_PERIPHERALS_BASE(0x0400)
#define PIO_TIMER_0_EP3SL_BASE 				          BRIDGE_PERIPHERALS_BASE(0x3000)
#define PIO_TIMER_1_EP3SL_BASE 				          BRIDGE_PERIPHERALS_BASE(0x3200)
#define PIO_INTERRUPTS_EP3SL_BASE 			       	BRIDGE_PERIPHERALS_BASE(0x4000)
#define PLLCFG_EGMVID_EP3SL_BASE								BRIDGE_PERIPHERALS_BASE(0x6000)
#define PLLCFG_S5VID_0_EP3SL_BASE					      BRIDGE_PERIPHERALS_BASE(0x6100)
#define PLLCFG_S5VID_1_EP3SL_BASE					      BRIDGE_PERIPHERALS_BASE(0x6200)
#define PRESENCE_ANALOGUE_EGMVID_EP3SL_BASE			BRIDGE_PERIPHERALS_BASE(0x6400)
#define PRESENCE_DVI_EGMVID_EP3SL_BASE			    BRIDGE_PERIPHERALS_BASE(0x6800)
#define PRESENCE_SDVO_S5VID_EP3SL_BASE			    BRIDGE_PERIPHERALS_BASE(0x6C00)

#define EP4C_BASE(a)                      			(FASTER_INTERFACE_0_BASE+a)

#define VIP_EGMVID_IN_BASE 				        			EP4C_BASE(VIP_EGMVID_IN_EP3SL_BASE)
#define VIP_EGMVID_CLIP_BASE 			        			EP4C_BASE(VIP_EGMVID_CLIP_EP3SL_BASE)
#define VIP_EGMVID_SCL_BASE 				        		EP4C_BASE(VIP_EGMVID_SCL_EP3SL_BASE)
#define VIP_EGMVID_ALPHA_BASE 						      EP4C_BASE(VIP_EGMVID_ALPHA_EP3SL_BASE)
#define VIP_S5VID_IN_BASE 			          			EP4C_BASE(VIP_S5VID_IN_EP3SL_BASE)
#define VIP_S5VID_CLIP_BASE 			        			EP4C_BASE(VIP_S5VID_CLIP_EP3SL_BASE)
#define VIP_S5VID_SCL_BASE 				        			EP4C_BASE(VIP_S5VID_SCL_EP3SL_BASE)
#define VIP_S5VID_ALPHA_BASE 						        EP4C_BASE(VIP_S5VID_ALPHA_EP3SL_BASE)
#define S5A_TILEMAP_SOURCE_0_REGS_BASE    			EP4C_BASE(VIP_TILEMAP_REGS_EP3SL_BASE)
#define ALPHA_TPG_BASE 						        			EP4C_BASE(VIP_TILEMAP_ALPHA_TPG_EP3SL_BASE)
#define VIP_OUTVID_MIXER_BASE 				        	EP4C_BASE(VIP_OUTVID_MIXER_EP3SL_BASE)
#define VIP_OUTVID_OUT_BASE 				        		EP4C_BASE(VIP_OUTVID_OUT_EP3SL_BASE)
#define VIP_EGMVID_SYNC_MASTER_BASE							EP4C_BASE(VIP_EGMVID_SYNC_MASTER_EP3SL_BASE)
#define VIP_EGMVID_SYNC_SLAVE_BASE							EP4C_BASE(VIP_EGMVID_SYNC_SLAVE_EP3SL_BASE)
#define VIP_S5VID_SYNC_MASTER_BASE							EP4C_BASE(VIP_S5VID_SYNC_MASTER_EP3SL_BASE)
#define VIP_S5VID_SYNC_SLAVE_BASE								EP4C_BASE(VIP_S5VID_SYNC_SLAVE_EP3SL_BASE)
#define S5A_TILEMAP_SOURCE_0_MEM_BASE     			EP4C_BASE(VIP_TILEMAP_MEM_EP3SL_BASE)
#define VIP_EGMVID_VFB_BASE                     EP4C_BASE(VIP_EGMVID_VFB_EP3SL_BASE)
#define VIP_S5VID_VFB_BASE                      EP4C_BASE(VIP_S5VID_VFB_EP3SL_BASE)
#define PIO_EGMVID_BASE 					        			EP4C_BASE(PIO_EGMVID_EP3SL_BASE)
#define PIO_VIDSEL_BASE 				          			EP4C_BASE(PIO_EGMVID_SEL_EP3SL_BASE)
#define PIO_INTERRUPTS_BASE 					          EP4C_BASE(PIO_INTERRUPTS_EP3SL_BASE)
#define PIO_S5VID_BASE 					        		    EP4C_BASE(PIO_S5VID_EP3SL_BASE)
#define PIO_DVI_CLK_BASE 					        			EP4C_BASE(PIO_DVI_CLK_EP3SL_BASE)
#define PIO_SDVO_CLK_BASE 					        		EP4C_BASE(PIO_SDVO_CLK_EP3SL_BASE)
#define PIO_DVO_CLK_BASE 					        			EP4C_BASE(PIO_DVO_CLK_EP3SL_BASE)
#define PIO_BASE_CLK_BASE 					        		EP4C_BASE(PIO_BASE_CLK_EP3SL_BASE)
#define PIO_OUTVID_BASE               			    EP4C_BASE(PIO_OUTVID_EP3SL_BASE)
#define PIO_VERSION_BASE 				          			EP4C_BASE(PIO_VERSION_EP3SL_BASE)
//#define PIO_ITC_0_BASE 				            			EP4C_BASE(PIO_ITC_0_EP3SL_BASE)
#define PLL_RECONFIG_CONDUIT_BASE								EP4C_BASE(PLLCFG_EGMVID_EP3SL_BASE)
#define PRESENCE_ANALOGUE_EGMVID_BASE			      EP4C_BASE(PRESENCE_ANALOGUE_EGMVID_EP3SL_BASE)
#define PRESENCE_DVI_EGMVID_BASE			          EP4C_BASE(PRESENCE_DVI_EGMVID_EP3SL_BASE)
#define PRESENCE_SDVO_S5VID_BASE			          EP4C_BASE(PRESENCE_SDVO_S5VID_EP3SL_BASE)

// PIO_INTERRUPTS
#define EP3SL_IRQ_VIP_S5VID_SYNC_SLAVE		(1<<13)
#define EP3SL_IRQ_VIP_S5VID_SYNC_MASTER		(1<<12)
#define EP3SL_IRQ_VIP_EGMVID_SYNC_SLAVE		(1<<11)
#define EP3SL_IRQ_VIP_EGMVID_SYNC_MASTER	(1<<10)
#define EP3SL_IRQ_PIO_OUTVID							(1<<9)
#define EP3SL_IRQ_VIP_EGMVID_IN		        (1<<8)
#define EP3SL_IRQ_VIP_S5VID_IN		        (1<<7)
#define EP3SL_IRQ_VIP_OUTVID_OUT	        (1<<6)
#define EP3SL_IRQ_PIO_S5VID			          (1<<5)
#define EP3SL_IRQ_TIMER_1			            (1<<4)
#define EP3SL_IRQ_PIO_EGMVID		          (1<<3)
#define EP3SL_IRQ_TIMER_0			            (1<<1)
// *** Don't enable this interrupt
#define EP3SL_IRQ_PIO_INTERRUPTS	        (1<<0)

// CTI/VL-DUALPIX REGISTERS
#define CTI_REG_CONTROL                   0x00
  #define CTI_CTRL_GO                     (1<<0)
#define CTI_REG_STATUS                    0x01
  #define CTI_STAT_RUNNING	              (1<<0)		// Core is running (data flowing)
  #define CTI_STAT_STABLE                 (1<<8)
  #define CTI_STAT_OVERFLOW	              (1<<9)		// Overflow occurred (write 1 to clear)
  #define CTI_STAT_RES_OK	                (1<<10)		// Resolution is reasonable

#define CTI_REG_INTERRUPT                 0x02
  #define INTERRUPT_SOF                   (1<<3)
  #define INTERRUPT_STABLE                (1<<2)
  #define INTERRUPT_STATUS                (1<<1)

// PIO_EGMVID/S5VID_BASE
// input register bits
#define PIO_SYNC_IN_HSYNC_XOR               (1<<0)
#define PIO_SYNC_IN_VSYNC_XOR               (1<<1)
// for analogue, these will always be +ve, since derived from hsout,vsout
#define PIO_SYNC_IN_HSYNC_POL               (1<<2)
#define PIO_SYNC_IN_VSYNC_POL               (1<<3)
#define PIO_SYNC_IN_LOCKED                  (1<<4)
#define PIO_SYNC_IN_STABLE                  (1<<5)
#define PIO_SYNC_IN_DVI_EGMVID_STABLE       (1<<10)
#define PIO_SYNC_IN_ANALOGUE_EGMVID_STABLE  (1<<11)
// output register bits
#define PIO_SYNC_IN_HSYNC_OVR             (1<<0)
#define PIO_SYNC_IN_HSYNC_OVR_INV         (1<<1)
#define PIO_SYNC_IN_VSYNC_OVR             (1<<2)
#define PIO_SYNC_IN_VSYNC_OVR_INV         (1<<3)
#define PIO_SYNC_IN_TVP7002_RESET         (1<<4)

// PIO_OUTVID_BASE
// input register bits
#define PIO_OUTVID_HSYNC                  (1<<0)
#define PIO_OUTVID_VSYNC                  (1<<1)
#define PIO_OUTVID_HSYNC_POS              (1<<2)
#define PIO_OUTVID_VSYNC_POS              (1<<3)
#define PIO_OUTVID_LOCKED                 (1<<4)
// output register bits                   
//#define PIO_OUTVID_HSYNC_OVR              PIO_SYNC_IN_HSYNC_OVR
#define PIO_OUTVID_HSYNC_OVR_INV          PIO_SYNC_IN_HSYNC_OVR_INV
//#define PIO_OUTVID_VSYNC_OVR              PIO_SYNC_IN_VSYNC_OVR
#define PIO_OUTVID_VSYNC_OVR_INV          PIO_SYNC_IN_VSYNC_OVR_INV
#define PIO_OUTVID_VAO_ENABLE             (1<<7)

// PIO_VIDSEL_BASE
#define PIO_VIDSEL_RESET_DVI              (1<<7)
#define PIO_VIDSEL_RESET_ANALOGUE         (1<<6)
#define PIO_VIDSEL_ANALOGUE               (PIO_VIDSEL_RESET_DVI|0x00)
#define PIO_VIDSEL_DVI                    (PIO_VIDSEL_RESET_ANALOGUE|0x01)

//
// EP4C
//

#define NIOS_CLK_Hz                 72000000

// VI/VO PIO BITS (valid for both IN and OUT)
#define VID_PIO_RESET               (1<<7)
#define VID_PIO_READY               (1<<6)
#define VID_PIO_PD                  (1<<4)
#define VID_PIO_OE                  (1<<3)
#define VID_PIO_CONNECT             (1<<2)
#define VID_PIO_PRESENT             (1<<1)
#define VID_PIO_HOTPLUG             (1<<0)
#define VID_PIO_HOTPLUG_IGNORE      (1<<0)

// USB_PIO
#define USB_LED_SPARE               (1<<3)
#define USB_LED_LOW                 (1<<2)
#define USB_LED_CLIENT              (1<<1)
#define USB_LED_HOST                (1<<0)
// only SPARE set to output atm
#define USB_PIO_DIR                 (USB_LED_CLIENT|USB_LED_HOST|USB_LED_SPARE)
#define USB_LED_ALL                 (USB_PIO_DIR)

// INTERRUPT (to the carrier) PIO
#define PIO_IRQ_VI_EGM              (1<<0)
#define PIO_IRQ_VI_S5               (1<<1)
#define PIO_IRQ_VO                  (1<<2)
#define PIO_IRQ_NIOS_READY          (1<<7)

#define FORCE_IDLE          (1<<4)
#define DVI_EN_I2C          (1<<3)     
#define DVI_EEP_WPn         (1<<2)     
#define REQ_FPG_DDC         (1<<1)
#define FPG_EEP_ACCESS      (1<<0)

//      -- DDC EEPROM enabling logic  
//      -- NOTE: this has been modified in the HDL to combine the 'dis' bits
//      --       so probably not much use documenting here...
//      --                dvi_en_i2c   dvi_eep_wp    dvi_dis_fpg_ddc   dvi_dis_eep_ddc
//      -- use EEP            1           1                 1                 0       
//      -- use FPGA           1           1                 0                 1       
//      -- write to EEP       1           0                 0                 1       
//      -- disconnect         0           1                 1                 1       
//      --
#define DVI_EEP_USE_EEP     (DVI_EN_I2C|DVI_EEP_WPn)
#define DVI_EEP_USE_FPGA    (DVI_EN_I2C|DVI_EEP_WPn|REQ_FPG_DDC|FPG_EEP_ACCESS)
#define DVI_EEP_WR_EEP      (DVI_EN_I2C|REQ_FPG_DDC|FPG_EEP_ACCESS)
#define DVI_EEP_DISCONNECT  (DVI_EEP_WPn)

#define RESET_PIO_OUT_TP7002_PDN    (1<<2)
#define RESET_PIO_OUT_VID_RESET     (1<<1)
#define RESET_PIO_OUT_IP_RESET   	  (1<<0)

// Debug LEDs
#define LED_VAO				(1<<0)
#define LED_VDO				(1<<1)
#define LED_VAI				(1<<2)
#define LED_VDI				(1<<3)
#define LED_VLI				(1<<4)
#define LED_VSI				(1<<5)
#define LED_NIOS_RDY  (1<<6)
#define LED_ALL       (0x7F)


#if 0
  // CMD,GFX FIFO hardware
  #define gfx_fifo ((1<<31)|GFX_FIFO_IF_BASE)
  #define cmd_fifo ((1<<31)|CMD_FIFO_IF_BASE)
  #define REG_FIFO_R_DATA       (0<<2)
  #define REG_FIFO_R_RDEMPTY    (1<<2)
    #define FIFO_RDEMPTY        (1<<0)
  #define REG_FIFO_R_WR_FULL    (2<<2)
  #define REG_FIFO_R_IRQ_CLR    (3<<2)
  #define REG_FIFO_W_DATA       (0<<2)
  #define REG_FIFO_W_BUSY       (1<<2)
    #define FIFO_BUSY           (1<<0)
  #define REG_FIFO_W_WR_CLR     (2<<2)
  #define REG_FIFO_W_IRQ        (3<<2)
    #define FIFO_IRQ            (1<<0)
#else
  #define HOST_IF_INIT()            spi_init()
  #define HOST_IF_TX(ep,buf,len)    mcuspi_tx_pkt(ep,buf,len)
  #define HOST_IF_DEINIT()          spi_deinit()
#endif
  
//
//  TVP7002
//

#define TVP7002_A   (0xB8>>1)

// OXU210HP

#define OXU210HP_GPIO_SPARE					(1<<3)
#define OXU210HP_GPIO_USB_LOW_EN		(1<<2)
#define OXU210HP_GPIO_USB_CLIENT_EN	(1<<1)
#define OXU210HP_GPIO_USB_HOST_EN		(1<<0)

#endif
