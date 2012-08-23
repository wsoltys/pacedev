#ifndef _USBDEV_OXU210_H_
#define	_USBDEV_OXU210_H_

#include "periph.h"

#define OXU210_NUM_PTDS 32	/* We should only need 2 transfer descriptors per endpoint max for now */

/* Structures alignment (bytes) */
#define	OXU210_DQH_ALIGN	64
#define	OXU210_DQH_TAB_ALIGN	4096

// Extra EHCI / other register definitions
#define OXU210_USBCMD		(0x140+EHCI_USBCMD)
#define OXU210_CMD_AT		(1<<14)		/* ptd tripwire */
#define OXU210_CMD_ST		(1<<13)		/* setup tripwire */

#define OXU210_USBMODE		(0x140+EHCI_USBMODE)
#define	OXU210_UM_CM_PERIPH	0x2	/* Peripheral Controller */
#define	OXU210_UM_CM_SL		0x8	/* Disable setup lockout */

#define OXU210_USBSTS		(0x140+EHCI_USBSTS)
#define	OXU210_STS_T1		0x02000000	/* timer 1 */
#define	OXU210_STS_T0		0x01000000	/* timer 0 */
#define	OXU210_STS_SU		0x00000100	/* suspend */
#define	OXU210_STS_SF		0x00000080	/* start of frame */
#define	OXU210_STS_UR		0x00000040	/* usb reset */

#define OXU210_USBINTR		(0x140+EHCI_USBINTR)
#define	OXU210_INTR_T1		0x02000000	/* timer 1 */
#define	OXU210_INTR_T0		0x01000000	/* timer 0 */
#define	OXU210_INTR_SE		0x00000100	/* sleep enable */
#define	OXU210_INTR_FE		0x00000080	/* start of frame */
#define	OXU210_INTR_RE		0x00000040	/* interrupt on usb reset */
#define	OXU210_STS_INTRS(x)	((x) & 0x030001ff)

#define OXU210_DEVADDR				(0x140+EHCI_PERIODICLISTBASE)
#define OXU210_SET_DEV_ADDR(x)		((x)<<25)
#define OXU210_ADDR_ADV_TRIG		(1<<24)

#define OXU210_EPLISTADDR			(0x140+EHCI_ASYNCLISTADDR)

#define OXU210_PORTSC               0x184
#define OXU210_GET_PORT_SPEED(x)    (((x) >> 26) & 3) 
#define OXU210_FORCE_FULL_SPEED		(1<<24)
#define OXU210_ENABLE_PHY_CLK		(1<<23)
#define OXU210_PORT_RESET			(1<<8)
#define OXU210_PORT_SUSPEND			(1<<7)
#define OXU210_FORCE_RESUME			(1<<6)
#define OXU210_PORT_CONNECT			(1<<0)

#define OXU210_ENDPT_SETUPSTAT		0x1AC
#define OXU210_ENDPT_PRIME			0x1B0
#define OXU210_ENDPT_FLUSH			0x1B4
#define OXU210_ENDPT_STAT			0x1B8
#define OXU210_ENDPT_COMPLETE		0x1BC
#define OXU210_ENDPT_PAIRCTRL(n)	(0x1C0 + 4*(n))
#define OXU210_EP_TX_EN				(1<<23)
#define OXU210_EP_TX_TOG_RESET		(1<<22)
#define OXU210_GET_TX_TYPE(x)		(((x)>>18)&0x3)
#define OXU210_SET_TX_TYPE(x)		(((x)&0x3)<<18)
#define OXU210_EP_TX_STALL			(1<<16)
#define OXU210_EP_RX_EN				(1<<7)
#define OXU210_EP_RX_TOG_RESET		(1<<6)
#define OXU210_GET_RX_TYPE(x)		(((x)>>2)&0x3)
#define OXU210_SET_RX_TYPE(x)		(((x)&0x3)<<2)
#define OXU210_EP_RX_STALL			(1<<0)

#define	OXU210_DCIVERSION			0x120	
#define OXU210_GET_DCIVERSION(x)	((x) & 0xffff)

#define	OXU210_DCCPARAMS			0x124
#define OXU210_DCCPARAMS_HC			(1<<8)
#define OXU210_DCCPARAMS_DC			(1<<7)
#define OXU210_GET_DCCPARAMS_DEN(x)	((x) & 0x1f)

/* Endpoint Queue Head */
struct oxu210_dqh {
	volatile uint32_t dqh_epcap;
#define OXU210_DQH_GET_IOS(x)		(((x) >> 15) &  0x1)
#define	OXU210_DQH_IOS				(1<<15)
#define	OXU210_DQH_GET_MAXLEN(x)	(((x) >> 16) &  0x7ff)
#define	OXU210_DQH_SET_MAXLEN(x)	(((x) & 0x7ff) << 16)
#define OXU210_DQH_GET_ZLT(x)		(((x) >> 29) &  0x1)
#define OXU210_DQH_ZLT				(1<<29)
#define OXU210_DQH_GET_MULT(x)		(((x) >> 30) &  0x3)
#define	OXU210_DQH_SET_MULT(x)		(((x) & 0x3) << 30)
#define OXU210_DQH_MULT_N			0x0
#define OXU210_DQH_MULT_1			0x1
#define OXU210_DQH_MULT_2			0x2
#define OXU210_DQH_MULT_3			0x3
	volatile uint32_t dqh_curptd;
	struct oxu210_ptd_sub dqh_ptd;
	volatile uint32_t dqh_resv;
	volatile uint32_t dqh_setup[2];

/* Endpoint Queue Extra Information */
	oxu210_ptdq_t ptd_list;	/* Transfer descriptor list */
} __aligned(OXU210_DQH_ALIGN);

typedef struct oxu210_dqh oxu210_dqh_t;

#ifdef QUEUE_MACRO_DEBUG
#error QUEUE_MACRO_DEBUG not supported because we need oxu210_dqh descriptor to fit in 64 bytes!
#endif

/* Endpoint Queue Extra Information */
//struct oxu210_dqh_ext {
//	struct oxu210_dqh *dqh;
//	uint32_t dqh_self;
//	struct usb_page_cache *page_cache;
//};
//
//typedef struct oxu210_dqh_ext oxu210_dqh_ext_t;

struct usbdev_hw_softc {
//	struct usb_page_cache pframes_pc;
//	struct usb_page_cache terminate_pc;
	struct usb_page_cache ep_dqh_pc;
	struct usb_page_cache ep_ptd_pc[OXU210_NUM_PTDS];
	struct usb_page_cache ep_buf_pc[OXU210_NUM_PTDS];

//	struct usb_page pframes_pg;
//	struct usb_page terminate_pg;
	struct usb_page ep_dqh_pg;
	struct usb_page ep_ptd_pg[OXU210_NUM_PTDS];
	struct usb_page ep_buf_pg[OXU210_NUM_PTDS];
};

/*
 * USB Device handlers.
 */
typedef struct
{
  void* sc;
  void (*event)(void* sc, usbdev_event_t evt, int arg);
  int  (*setup)(void* sc, uint8_t ep, usb_device_request_t* req);
  int  (*complete)(void* sc, uint8_t ep, oxu210_ptd_t* ptd, ptd_status_t status);
} usbdev_handlers_t;

struct usbdev_softc {
	struct usbdev_hw_softc sc_hw;
	device_t sc_dev;

	bus_size_t sc_io_size;
	bus_space_tag_t sc_io_tag;
	bus_space_handle_t sc_io_hdl;
//	struct oxu210_dqh_ext sc_dqe[OXU210_EP_COUNT];
	struct oxu210_dqh *sc_dqh;
	uint32_t sc_dqe_base;
	oxu210_ptdq_t ptd_free;	/* Transfer descriptor free list */

	uint32_t sc_intrs;		/* shadow of interrupt register */
	uint32_t sc_cmd;		/* shadow of cmd register */
	uint32_t sc_status;		/* status register saved during interrupt */
	uint32_t sc_oldstatus;	/* previous status register saved during interrupt */

	uint16_t sc_flags;		/* chip specific flags */
#define	EHCI_SCFLG_SETMODE	0x0001	/* set bridge mode again after init */
#define	EHCI_SCFLG_FORCESPEED	0x0002	/* force speed */
#define	EHCI_SCFLG_NORESTERM	0x0004	/* don't terminate reset sequence */
#define	EHCI_SCFLG_BIGEDESC	0x0008	/* big-endian byte order descriptors */
#define	EHCI_SCFLG_BIGEMMIO	0x0010	/* big-endian byte order MMIO */
#define	EHCI_SCFLG_TT		0x0020	/* transaction translator present */
#define	EHCI_SCFLG_LOSTINTRBUG	0x0040	/* workaround for VIA / ATI chipsets */
#define	EHCI_SCFLG_IAADBUG	0x0080	/* workaround for nVidia chipsets */

	uint8_t	sc_offs;		/* offset to operational registers */
	uint8_t	sc_doorbell_disable;	/* set on doorbell failure */
	uint8_t	sc_noport;
	uint8_t	sc_addr;		/* device address */
	uint8_t	sc_conf;		/* device configuration */
	uint8_t	sc_isreset;

  usbdev_handlers_t* handlers;

	/*
	 * This mutex protects the USB hardware:
	 */
	struct mtx bus_mtx;

#if USB_HAVE_BUSDMA
	struct usb_dma_parent_tag dma_parent_tag[1];
	struct usb_dma_tag dma_tags[USB_BUS_DMA_TAG_MAX];
#endif

	uint8_t	alloc_failed;		/* Set if memory allocation failed. */

};

#ifdef USB_EHCI_BIG_ENDIAN_DESC
/*
 * Handle byte order conversion between host and ``host controller''.
 * Typically the latter is little-endian but some controllers require
 * big-endian in which case we may need to manually swap.
 */
static __inline uint32_t
dtohc32(const struct usbdev_softc *sc, const uint32_t v)
{
	return v;
}

static __inline uint16_t
dtohc16(const struct usbdev_softc *sc, const uint16_t v)
{
	return v;
}

static __inline uint32_t
hc32tod(const struct usbdev_softc *sc, const uint32_t v)
{
	return v;
}

static __inline uint16_t
hc16tod(const struct usbdev_softc *sc, const uint16_t v)
{
	return v;
}
#else
/*
 * Normal little-endian only conversion routines.
 */
static __inline uint32_t
dtohc32(const struct usbdev_softc *sc, const uint32_t v)
{
	return v;
}

static __inline uint16_t
dtohc16(const struct usbdev_softc *sc, const uint16_t v)
{
	return v;
}

static __inline uint32_t
hc32tod(const struct usbdev_softc *sc, const uint32_t v)
{
	return v;
}

static __inline uint16_t
hc16tod(const struct usbdev_softc *sc, const uint16_t v)
{
	return v;
}
#endif

extern void usbdev_handle_event(usbdev_softc_t* sc, usbdev_event_t evt, int arg);
extern int  usbdev_ep_primed(usbdev_softc_t* sc, uint8_t ep_idx);
extern void usbdev_flush_and_clear_endpoint(usbdev_softc_t* sc, uint8_t ep_idx);
extern void usbdev_reset_ptd(usbdev_softc_t* sc, oxu210_ptd_t *ptd);
extern void usbdev_stall_ep(usbdev_softc_t* sc, uint8_t ep);
extern void usbdev_unstall_ep(usbdev_softc_t* sc, uint8_t ep);
extern void usbdev_set_ep_enable(usbdev_softc_t* sc, uint8_t ep,
                                 int in_maxlen, int in_type, int out_maxlen, int out_type);
extern void usbdev_set_ep_disable(usbdev_softc_t* sc, uint8_t ep);
extern void usbdev_set_ep_disable_all(usbdev_softc_t* sc);
extern void usbdev_set_address(usbdev_softc_t* sc, uint8_t addr);
extern usb_error_t usbdev_queue_ptd(usbdev_softc_t* sc, uint8_t ep_idx, oxu210_ptd_t *ptd);
extern usb_error_t usbdev_queue_xfer(usbdev_softc_t* sc, uint8_t ep,
                                     const uint8_t *txbuf, uint16_t txlen);

#endif					/* _USBDEV_OXU210_H_ */

