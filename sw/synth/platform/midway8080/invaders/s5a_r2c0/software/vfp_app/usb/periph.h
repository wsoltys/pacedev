#ifndef _PERIPH_H_
#define	_PERIPH_H_

#define arraylen(n) (sizeof(n) / sizeof((n)[0]))

#define INBOUND(n)  (0x80|(n))
#define OUTBOUND(n) (n)

// OXU210 descriptor id conversion macros
#define OXU210_EP_COUNT 32
#define OXU210_EP_PAIR_COUNT (OXU210_EP_COUNT / 2)
#define OXU210_EP_OUT_IDX(n)	(((uint32_t)(n)<<1)+0)
#define OXU210_EP_IN_IDX(n)		(((uint32_t)(n)<<1)+1)
#define OXU210_EP_IDX_IS_IN(n)	((n) & 1)
#define OXU210_EP_IDX_NUM(n)	((n) >> 1)
#define OXU210_EP_OUT_BIT(n)	(1<<((uint32_t)n))
#define OXU210_EP_IN_BIT(n)		(1<<((uint32_t)(n)+16))
#define OXU210_EP_BIT_IS_TX(n)	((n) & 16)
#define OXU210_EP_BIT_TO_IDX(n)	((n & 0x0f) << 1 | ((n & 0x10) >> 4))		/* EP bit to dqh num */
#define OXU210_EP_IDX_TO_BIT(n)	((n & 0x1e) >> 1 | ((n & 0x1) << 4))		/* dqh num to EP bit */

/* Max buffer size per PTD (currently fixed length buffers) */
#define OXU210_PTD_BUFSIZE 64	

/* Structures alignment (bytes) */
#define	OXU210_PTD_ALIGN	64

/* Link types */
#define	OXU210_LINK_TERMINATE	0x00000001
#define	OXU210_LINK_TYPE(x)	((x) & 0x00000006)
#define	OXU210_LINK_ADDR(x)	((x) &~ 0x1f)

#define OXU210_PORT_FULL_SPEED      0
#define OXU210_PORT_LOW_SPEED   	1
#define OXU210_PORT_HIGH_SPEED      2

/*
 * These are in the USB stack code. Why are they not used ?
 */
#define OXU210_TYPE_CTRL			0
#define OXU210_TYPE_ISO				1
#define OXU210_TYPE_BULK			2
#define OXU210_TYPE_INTR			3
#define OXU210_TYPE_NONE			OXU210_TYPE_BULK

struct oxu210_ptd_sub {
	volatile uint32_t ptd_next;
	volatile uint32_t ptd_status;
#define	OXU210_PTD_GET_STATUS(x)	(((x) >>  0) & 0xff)
#define	OXU210_PTD_SET_STATUS(x)	((x) << 0)
#define	OXU210_PTD_ACTIVE			0x80
#define	OXU210_PTD_HALTED			0x40
#define	OXU210_PTD_BUFERR			0x20
#define	OXU210_PTD_TRANS			0x10
#define OXU210_PTD_GET_MULTO(x)		(((x) >> 10) &  0x3)
#define	OXU210_PTD_SET_MULTO(x)		(((x) & 0x3) << 10)
#define	OXU210_PTD_GET_IOC(x)		(((x) >> 15) &  0x1)
#define	OXU210_PTD_IOC				(1<<15)
#define	OXU210_PTD_GET_BYTES(x)		(((x) >> 16) &  0x7fff)
#define	OXU210_PTD_SET_BYTES(x)		(((x) & 0x7fff) << 16)
#define	OXU210_PTD_GET_FRAMENUM(x)	(((x) >> 0) & 0x7ff)
#define	OXU210_PTD_SET_FRAMENUM(x)	(((x) & 0x7ff) << 0)
#define OXU210_PTD_NBUFFERS	5
#define	OXU210_PTD_PAYLOAD_MAX ((OXU210_PTD_NBUFFERS-1)*EHCI_PAGE_SIZE)
	volatile uint32_t ptd_buffer[OXU210_PTD_NBUFFERS];
} __aligned(4);

/* Endpoint Transfer Descriptor */
struct oxu210_ptd {
	struct oxu210_ptd_sub ptd;
/*
 * Extra information needed:
 */
	struct usb_page_cache *page_cache;
	struct usb_page_cache *buf_page_cache;
	uint32_t ptd_self;
	uint32_t *buf_ptr;
	uint16_t buf_size;
	uint16_t len;
	TAILQ_ENTRY(oxu210_ptd) entry;	/* free list queue entry */
} __aligned(OXU210_PTD_ALIGN);
typedef struct oxu210_ptd oxu210_ptd_t;
typedef TAILQ_HEAD(oxu210_ptdq, oxu210_ptd ) oxu210_ptdq_t;

enum ptd_status {
	STATUS_COMPLETE = 0,
	STATUS_FLUSHED	= 1
};
typedef enum ptd_status ptd_status_t;

struct usbdev_softc;
typedef struct usbdev_softc usbdev_softc_t;

enum usbdev_event {
	EVENT_RESET			= 0,
	EVENT_CONNECT		= 1,
	EVENT_CONFIGURED	= 2,
	EVENT_SUSPEND		= 3
};
typedef enum usbdev_event usbdev_event_t;

#define DESC_MAX_TABLE_SIZE 32

// Descriptor table entry
struct periph_desc {
	uint32_t		desc_id;
	uint8_t			*desc_buf;
	uint16_t		desc_len;
};
typedef struct periph_desc periph_desc_t;

// Descriptor ID is <bRequest>,<bmRequestType>,<wValue> packed into 32-bit word
#define DESC_ID_GET_REQ(id)		(((id) >> 24) & 0xff)
#define DESC_ID_SET_REQ(id)		(((id) & 0xff) << 24)
#define DESC_ID_GET_REQTYPE(id)	(((id) >> 16) & 0xff)
#define DESC_ID_SET_REQTYPE(id)	(((id) & 0xff) << 16)
#define DESC_ID_GET_DTYPE(id)	((id) & 0xff)
#define DESC_ID_SET_DTYPE(id)	((id) & 0xff)
#define DESC_ID_GET_DIDX(id)	(((id) >> 8) & 0xff)
#define DESC_ID_SET_DIDX(id)	(((id) & 0xff) << 8)

#define DESC_ID_STD		(DESC_ID_SET_REQ(UR_GET_DESCRIPTOR) | DESC_ID_SET_REQTYPE(UT_READ_DEVICE))
#define DESC_ID_VEND	(DESC_ID_SET_REQTYPE(UT_READ_VENDOR_DEVICE))
#define DESC_ID_END		0

#endif	//_PERIPH_H_

