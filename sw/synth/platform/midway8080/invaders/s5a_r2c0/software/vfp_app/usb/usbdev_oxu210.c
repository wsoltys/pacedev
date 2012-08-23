#include <io.h>
#include <system.h>

#include "usb.h"
#include "usbdi.h"

#define	USB_DEBUG_VAR usbdevdebug

#include "usb_util.h"
#include "usb_core.h"
#include "usb_debug.h"
#include "usb_busdma.h"
#include "usb_process.h"
#include "usb_transfer.h"
#include "usb_device.h"
#include "usb_hub.h"
#include "usb_util.h"

#include "usb_controller.h"
#include "usb_bus.h"
#include "usbdev_oxu210.h"
#include "ehci.h"
#include "ehcireg.h"

#include "s5a-sysinit.h"

#include "../os-support.h"
#include "../dbg_helper.h"
#include "../oxu210hp.h"
#include "oxu210-intr.h"

#include "pdev.h"

#define OXU210HP_USBDEV_STR "Oxford USB 2.0 controller (device)"

#define OXU210_USB_OTG_OFST  (0x0400 + 0x100)

typedef void (usbdev_mem_sub_cb_t)(usbdev_softc_t *sc, struct usb_page_cache *pc,
                                   struct usb_page *pg, usb_size_t size, usb_size_t align);
typedef void (usbdev_mem_cb_t)(usbdev_softc_t *sc, usbdev_mem_sub_cb_t *scb);

#if USB_HAVE_BUSDMA
static void usbdev_mem_flush_all_cb(usbdev_softc_t *sc, struct usb_page_cache *pc,
									struct usb_page *pg, usb_size_t size, usb_size_t align);
static void usbdev_mem_flush_all(usbdev_softc_t *sc, usbdev_mem_cb_t *cb);
static void usbdev_mem_alloc_all_cb(usbdev_softc_t *sc, struct usb_page_cache *pc,
									struct usb_page *pg, usb_size_t size, usb_size_t align);
static uint8_t usbdev_mem_alloc_all(usbdev_softc_t *sc, bus_dma_tag_t dmat,
									usbdev_mem_cb_t *cb);
static void usbdev_mem_free_all_cb(usbdev_softc_t *sc, struct usb_page_cache *pc,
								   struct usb_page *pg, usb_size_t size, usb_size_t align);
static void usbdev_mem_free_all(usbdev_softc_t *sc, usbdev_mem_cb_t *cb);
#endif

#ifdef USB_DEBUG
static int usbdevdebug = 1; //USB_DEBUG;
#endif

static volatile int isr_thread_id = 0;
static volatile int isr_thread_running;

static void usbdev_flush_endpoints(usbdev_softc_t* sc);
static usb_error_t usbdev_init(usbdev_softc_t *sc);

static void
usbdev_iterate_hw_softc(usbdev_softc_t *sc, usbdev_mem_sub_cb_t *cb)
{
	uint32_t i;

	cb(sc, &sc->sc_hw.ep_dqh_pc,
	   &sc->sc_hw.ep_dqh_pg,
	   OXU210_EP_COUNT * OXU210_DQH_ALIGN, OXU210_DQH_TAB_ALIGN);

	for (i = 0; i != OXU210_NUM_PTDS; i++) {
		cb(sc, sc->sc_hw.ep_ptd_pc + i,
		   sc->sc_hw.ep_ptd_pg + i,
		   sizeof(oxu210_ptd_t), OXU210_PTD_ALIGN);
	}

	for (i = 0; i != OXU210_NUM_PTDS; i++) {
		cb(sc, sc->sc_hw.ep_buf_pc + i,
		   sc->sc_hw.ep_buf_pg + i,
		   OXU210_PTD_BUFSIZE, OXU210_PTD_BUFSIZE);
	}
}

/*------------------------------------------------------------------------*
 *	usbdev_mem_flush_all_cb
 *------------------------------------------------------------------------*/
#if USB_HAVE_BUSDMA
static void
usbdev_mem_flush_all_cb(usbdev_softc_t *sc, struct usb_page_cache *pc,
						struct usb_page *pg, usb_size_t size, usb_size_t align)
{
	usb_pc_cpu_flush(pc);
}
#endif

/*------------------------------------------------------------------------*
 *	usbdev_mem_flush_all - factored out code
 *------------------------------------------------------------------------*/
#if USB_HAVE_BUSDMA
static void
usbdev_mem_flush_all(usbdev_softc_t *sc, usbdev_mem_cb_t *cb)
{
	if (cb) {
		cb(sc, &usbdev_mem_flush_all_cb);
	}
}
#endif

/*------------------------------------------------------------------------*
 *	usbdev_mem_alloc_all_cb
 *------------------------------------------------------------------------*/
#if USB_HAVE_BUSDMA
static void
usbdev_mem_alloc_all_cb(usbdev_softc_t *sc, struct usb_page_cache *pc,
						struct usb_page *pg, usb_size_t size, usb_size_t align)
{
	/* need to initialize the page cache */
	pc->tag_parent = sc->dma_parent_tag;

	if (usb_pc_alloc_mem(pc, pg, size, align)) {
		sc->alloc_failed = 1;
	}
}
#endif

/*------------------------------------------------------------------------*
 *	usbdev_mem_alloc_all - factored out code
 *
 * Returns:
 *    0: Success
 * Else: Failure
 *------------------------------------------------------------------------*/
static uint8_t
usbdev_mem_alloc_all(usbdev_softc_t *sc, bus_dma_tag_t dmat,
					 usbdev_mem_cb_t *cb)
{
	sc->alloc_failed = 0;

	mtx_init(&sc->bus_mtx, device_get_nameunit(sc->sc_dev),
			 NULL, MTX_DEF | MTX_RECURSE);

//	usb_callout_init_mtx(&bus->power_wdog,
//	    &bus->bus_mtx, 0);

	TAILQ_INIT(&sc->ptd_free);

#if USB_HAVE_BUSDMA
	usb_dma_tag_setup(sc->dma_parent_tag, sc->dma_tags,
					  dmat, &sc->bus_mtx, NULL, 32, USB_BUS_DMA_TAG_MAX);
	if (cb) {
		cb(sc, &usbdev_mem_alloc_all_cb);
	}
#endif
	if (sc->alloc_failed) {
		usbdev_mem_free_all(sc, cb);
	}
	return(sc->alloc_failed);
}

/*------------------------------------------------------------------------*
 *	usbdev_mem_free_all_cb
 *------------------------------------------------------------------------*/
#if USB_HAVE_BUSDMA
static void
usbdev_mem_free_all_cb(usbdev_softc_t *sc, struct usb_page_cache *pc,
					   struct usb_page *pg, usb_size_t size, usb_size_t align)
{
	usb_pc_free_mem(pc);
}
#endif

/*------------------------------------------------------------------------*
 *	usbdev_mem_free_all - factored out code
 *------------------------------------------------------------------------*/
static void
usbdev_mem_free_all(usbdev_softc_t *sc, usbdev_mem_cb_t *cb)
{
#if USB_HAVE_BUSDMA
	if (cb) {
		cb(sc, &usbdev_mem_free_all_cb);
	}
	usb_dma_tag_unsetup(sc->dma_parent_tag);
#endif

	mtx_destroy(&sc->bus_mtx);
}

static void
oxu210_halt()
{
	while(1)
		usb_pause_mtx(NULL, hz / 1000);
}

static void
usbdev_dbg_print_dqh(oxu210_dqh_t *dqh, int id)
{
	DPRINTF("dqh[%d] epcap      = %08lx\n", id, dqh->dqh_epcap);
	DPRINTF("dqh[%d] curptd     = %08lx\n", id, dqh->dqh_curptd);
	DPRINTF("dqh[%d] ptd next   = %08lx\n", id, dqh->dqh_ptd.ptd_next);
	DPRINTF("dqh[%d] ptd status = %08lx\n", id, dqh->dqh_ptd.ptd_status);
	DPRINTF("dqh[%d] ptd buf[0] = %08lx\n", id, dqh->dqh_ptd.ptd_buffer[0]);
	DPRINTF("dqh[%d] ptd buf[1] = %08lx\n", id, dqh->dqh_ptd.ptd_buffer[1]);
}

static void
usbdev_dbg_print_ptd(oxu210_ptd_t *ptd)
{
	DPRINTF("ptd next   = %08lx\n", ptd->ptd.ptd_next);
	DPRINTF("ptd status = %08lx\n", ptd->ptd.ptd_status);
	DPRINTF("ptd buf[0] = %08lx\n", ptd->ptd.ptd_buffer[0]);
	DPRINTF("ptd buf[1] = %08lx\n", ptd->ptd.ptd_buffer[1]);
}

#ifdef USB_DEBUG
static int
usbdev_dbg_list_count(oxu210_ptdq_t* list)
{
  oxu210_ptd_t* node;
  int count = 0;
  TAILQ_FOREACH(node, list, entry)
    ++count;
  return count;
}

static int
usbdev_dbg_device_count(oxu210_dqh_t* dqh)
{
  oxu210_ptd_t* node = (oxu210_ptd_t *)dqh->dqh_ptd.ptd_next;
  int count = 0;
  while ((((uint32_t)node & 1) == 0) && (count < 100))
  {
    ++count;
    node = (oxu210_ptd_t*) node->ptd.ptd_next;
  }
  return count;
}

static void
do_usbdev_dbg_list_counts(int level, usbdev_softc_t *sc)
{
  if (usbdevdebug >= level)
  {
    int ep;
    int cnt;
    printf ("FQ=%d ", usbdev_dbg_list_count(&sc->ptd_free));
    for (ep = 0, cnt = 0; ep < OXU210_EP_COUNT; ++ep)
    {
      int lc = usbdev_dbg_list_count(&sc->sc_dqh[ep].ptd_list);
      int dc = usbdev_dbg_device_count(&sc->sc_dqh[ep]);
      if (lc || dc)
      {
        printf (" EPQ[%d]=%d/%d ", ep, lc, dc);
        if (cnt && ((cnt % 4) == 0))
          printf ("\n");
        ++cnt;
      }
    }
    printf ("\n");
  }
}
#define usbdev_dbg_list_counts(_sc, _l, _h, ...) \
  DPRINTFN(_l, _h ":", ## __VA_ARGS__); do_usbdev_dbg_list_counts (_l, _sc)
#else
#define usbdev_dbg_list_counts(_sc, _l, _h, ...)
#endif

usb_error_t
usbdev_reset(usbdev_softc_t *sc)
{
	uint32_t hcr;
	int i;

	// Flush endpoints and stop
	usbdev_flush_endpoints(sc);
	OXU210HP_OTG_WR(OXU210_USBCMD, (sc->sc_cmd & ~(EHCI_CMD_RS)));

	// Reset controller and wait for reset to complete
	OXU210HP_OTG_WR(OXU210_USBCMD, (sc->sc_cmd & ~(EHCI_CMD_RS)) | EHCI_CMD_HCRESET);
	for (i = 0; i < 100; i++) {
		usb_pause_mtx(NULL, hz / 1000);
		hcr = OXU210HP_OTG_RD(OXU210_USBCMD) & EHCI_CMD_HCRESET;
		if (!hcr) {
			if (sc->sc_flags & (EHCI_SCFLG_SETMODE | EHCI_SCFLG_BIGEMMIO)) {
				/*
				 * Force USBMODE as requested.  Controllers
				 * may have multiple operating modes.
				 */
				uint32_t usbmode = OXU210HP_OTG_RD(OXU210_USBMODE);
				if (sc->sc_flags & EHCI_SCFLG_SETMODE) {
					usbmode = (usbmode &~ EHCI_UM_CM) | OXU210_UM_CM_PERIPH;
					device_printf(sc->sc_dev,
								  "set peripheral controller mode\n");
				}
				if (sc->sc_flags & EHCI_SCFLG_BIGEMMIO) {
					usbmode = (usbmode &~ EHCI_UM_ES) | EHCI_UM_ES_BE;
					device_printf(sc->sc_dev,
								  "set big-endian mode\n");
				}
				usbmode |= OXU210_UM_CM_SL;
				OXU210HP_OTG_WR(OXU210_USBMODE, usbmode);
			}
      
			return(0);
		}
	}
	DPRINTF("reset timeout\n");
	return(USB_ERR_IOERROR);
}

static inline void
usbdev_enable_ints (void)
{
	OXU210HP_HOSTIF_WR (R_ChipIRQEn_Set, ChipIRQEn_OE);
}

static inline void
usbdev_disable_ints (void)
{
	OXU210HP_HOSTIF_WR (R_ChipIRQEn_Clr, ChipIRQEn_OE);
}

void
usbdev_reset_ptd(usbdev_softc_t* sc, oxu210_ptd_t *ptd) 
{
	struct usb_page_search buf_res;

	// Ensure sane values
	ptd->ptd.ptd_next = dtohc32(sc, OXU210_LINK_TERMINATE);
	ptd->ptd.ptd_status = OXU210_PTD_IOC | OXU210_PTD_ACTIVE;
	usbd_get_page(ptd->buf_page_cache, 0, &buf_res);
	ptd->ptd.ptd_buffer[0] = dtohc32(sc, buf_res.physaddr);
	ptd->ptd.ptd_buffer[1] = 0;
	ptd->ptd.ptd_buffer[2] = 0;
	ptd->ptd.ptd_buffer[3] = 0;
	ptd->ptd.ptd_buffer[4] = 0;
}

// Take a PTD off the free list, return 0 if none available
// Ensure device / interrupt lock held
static inline oxu210_ptd_t *
usbdev_alloc_ptd(usbdev_softc_t* sc, uint16_t len)
{
	oxu210_ptd_t *ptd;

	// Check size
	if(len > OXU210_PTD_BUFSIZE)
		return 0;

	// Find a spare PTD
	ptd = TAILQ_FIRST(&sc->ptd_free);
	if(ptd) {
		TAILQ_REMOVE(&sc->ptd_free, ptd, entry);

		usbdev_reset_ptd(sc, ptd); 
		ptd->ptd.ptd_status = ptd->ptd.ptd_status | OXU210_PTD_SET_BYTES(len);
		ptd->len = len;
	}
  
	return ptd;
}

// Return a PTD to the free list
// Ensure device / interrupt lock held
static inline void
usbdev_free_ptd(usbdev_softc_t* sc, oxu210_ptd_t *ptd)
{
	TAILQ_INSERT_TAIL(&sc->ptd_free, ptd, entry);
}

// Free all outstanding transfer descriptors, regardless of status
static void
usbdev_free_all_ptds(usbdev_softc_t* sc) 
{
	int n;
	for(n=0; n<OXU210_EP_COUNT; ++n) {
		oxu210_dqh_t *dqh = &sc->sc_dqh[n];
		// Free queued transfer descriptors
		while(!TAILQ_EMPTY(&dqh->ptd_list)) {
			oxu210_ptd_t *ptd = TAILQ_FIRST(&dqh->ptd_list);
			TAILQ_REMOVE(&dqh->ptd_list, ptd, entry);
			usbdev_free_ptd(sc, ptd);
		}
	}
}

// Check if there is a PTD ready to go on a given endpoint
int
usbdev_ep_primed(usbdev_softc_t* sc, uint8_t ep_idx)
{
	return OXU210HP_OTG_RD(OXU210_ENDPT_STAT) & (1<<OXU210_EP_IDX_TO_BIT(ep_idx));
}

static void
usbdev_flush_endpoints(usbdev_softc_t* sc)
{
	uint32_t complete;
	// Clear primed transfers
	do {
		complete = OXU210HP_OTG_RD(OXU210_ENDPT_PRIME);
	} while(complete);

redo_flush:
	// Flush primed transfers (may take a long time)
	OXU210HP_OTG_WR(OXU210_ENDPT_FLUSH, (uint32_t)-1);
	do {
		complete = OXU210HP_OTG_RD(OXU210_ENDPT_FLUSH);
	} while(complete);

	// Check if flush was refused due to packet procesing in progress
	if(OXU210HP_OTG_RD(OXU210_ENDPT_STAT))
		goto redo_flush;

	// Reset dqh next pointer
	int n;
  if (sc->sc_dqh) {
	for(n=0; n<OXU210_EP_COUNT; ++n) {
		oxu210_dqh_t *dqh = &sc->sc_dqh[n];
		dqh->dqh_ptd.ptd_next = dtohc32(sc, OXU210_LINK_TERMINATE);
	}
  }
}

static void
usbdev_dispatch_periph_event (struct usbdev_softc *sc, usbdev_event_t evt, int arg)
{
  if (sc->handlers->event)
    sc->handlers->event (sc->handlers->sc, evt, arg);
}

static void
usbdev_dispatch_periph_setup (struct usbdev_softc * sc,
                              uint8_t               ep,
                              usb_device_request_t* req)
{
  if (sc->handlers->setup)
    sc->handlers->setup (sc->handlers->sc, ep, req);
}

static void
usbdev_dispatch_periph_complete (struct usbdev_softc *sc,
                                 uint8_t             ep,
                                 oxu210_ptd_t*       ptd,
                                 ptd_status_t        status)
{
  int r = 1;
  if (sc->handlers->complete)
    r = sc->handlers->complete (sc->handlers->sc, ep, ptd, status);
  if (r)
    usbdev_free_ptd(sc, ptd);
}

static void
usbdev_flush_endpoint(usbdev_softc_t* sc, uint8_t ep_idx)
{
	uint32_t ep_bit = 1<<OXU210_EP_IDX_TO_BIT(ep_idx);
	uint32_t complete;
	// Clear primed transfer
	do {
		complete = OXU210HP_OTG_RD(OXU210_ENDPT_PRIME) & ep_bit;
	} while(complete);

redo_flush:
	// Flush primed transfer (may take a long time)
	OXU210HP_OTG_WR(OXU210_ENDPT_FLUSH, ep_bit);
	do {
		complete = OXU210HP_OTG_RD(OXU210_ENDPT_FLUSH) & ep_bit;
	} while(complete);

	// Check if flush was refused due to packet procesing in progress
	if(OXU210HP_OTG_RD(OXU210_ENDPT_STAT) & ep_bit)
		goto redo_flush;

	// Reset dqh next pointer
	oxu210_dqh_t *dqh = &sc->sc_dqh[ep_idx];
	dqh->dqh_ptd.ptd_next = dtohc32(sc, OXU210_LINK_TERMINATE);
}

// Flush endpoint and free and queued descriptors
void
usbdev_flush_and_clear_endpoint(usbdev_softc_t* sc, uint8_t ep_idx)
{
	// Free IN queued transfer descriptors
	oxu210_dqh_t *idqh = &sc->sc_dqh[ep_idx];
  
  DPRINTFN(10, "ep=%d\n", ep_idx);
  
  usbdev_dbg_list_counts (sc, 25, "in:%d:e=%c",
                          ep_idx, TAILQ_EMPTY(&idqh->ptd_list) ? 'y' : 'n');

	usbdev_flush_endpoint(sc, ep_idx);

	while(!TAILQ_EMPTY(&idqh->ptd_list)) {
		oxu210_ptd_t *ptd = TAILQ_FIRST(&idqh->ptd_list);
		TAILQ_REMOVE(&idqh->ptd_list, ptd, entry);
    usbdev_dispatch_periph_complete (sc, ep_idx, ptd, STATUS_FLUSHED);
    usbdev_dbg_list_counts (sc, 29, "do");
	}

  usbdev_dbg_list_counts (sc, 25, "out");
}

// Stall an endpoint pair
void 
usbdev_stall_ep(usbdev_softc_t* sc, uint8_t ep) 
{
	uint32_t epctl = OXU210HP_OTG_RD(OXU210_ENDPT_PAIRCTRL(ep));
	epctl |= OXU210_EP_TX_STALL | OXU210_EP_RX_STALL;
	OXU210HP_OTG_WR(OXU210_ENDPT_PAIRCTRL(ep), epctl);
}

// Unstall an endpoint pair
void 
usbdev_unstall_ep(usbdev_softc_t* sc, uint8_t ep) 
{
	uint32_t epctl = OXU210HP_OTG_RD(OXU210_ENDPT_PAIRCTRL(ep));
	epctl &= ~(OXU210_EP_TX_STALL | OXU210_EP_RX_STALL);
	OXU210HP_OTG_WR(OXU210_ENDPT_PAIRCTRL(ep), epctl);
}

// Enable or disable endpoint pair, set maxlen to max packet size, or < 0 to
// disable endpoint
// Note the datasheet suggests not to change maxlen while endpoint is live,
// that would be bad
void
usbdev_set_ep_enable(usbdev_softc_t* sc, uint8_t ep, int in_maxlen,
                     int in_type, int out_maxlen, int out_type)
{
	oxu210_dqh_t *dqh;

  DPRINTFN(10, "ep=%d in=%d/%d out=%d/%d\n",
           ep, in_type, in_maxlen, out_type, out_maxlen);
  
	// Set disabled endpoints first
	uint32_t epctl = OXU210HP_OTG_RD(OXU210_ENDPT_PAIRCTRL(ep));
	if(in_maxlen < 0) {
    // Disabled EP must have type != 0
		epctl = (epctl & 0x0000ffff) | OXU210_SET_TX_TYPE(OXU210_TYPE_BULK);
		OXU210HP_OTG_WR(OXU210_ENDPT_PAIRCTRL(ep), epctl);
	}
	if(out_maxlen < 0) {
		epctl = (epctl & 0xffff0000) | OXU210_SET_RX_TYPE(OXU210_TYPE_BULK);
		OXU210HP_OTG_WR(OXU210_ENDPT_PAIRCTRL(ep), epctl);
	}

	// Setup queue heads appropriately
	dqh = &sc->sc_dqh[OXU210_EP_IN_IDX(ep)];
	if(in_maxlen < 0) {
		dqh->dqh_epcap = 0;
	} else {
		dqh->dqh_epcap = dtohc32(sc, OXU210_DQH_SET_MAXLEN(in_maxlen) | OXU210_DQH_IOS);
	}
	dqh = &sc->sc_dqh[OXU210_EP_OUT_IDX(ep)];
	if(out_maxlen < 0) {
		dqh->dqh_epcap = 0;
	} else {
		dqh->dqh_epcap = dtohc32(sc, OXU210_DQH_SET_MAXLEN(out_maxlen) | OXU210_DQH_IOS);
	}

	// Set enabled endpoints
	if(in_maxlen >= 0) {
		//device_printf(sc->sc_dev, "en ep %d epctl = %08x\n", ep, epctl);
		epctl = (epctl & 0x0000ffff) | OXU210_EP_TX_EN | OXU210_EP_TX_TOG_RESET | OXU210_SET_TX_TYPE(in_type);
		//device_printf(sc->sc_dev, "        epctl = %08x\n", epctl);
		OXU210HP_OTG_WR(OXU210_ENDPT_PAIRCTRL(ep), epctl);
	}
	if(out_maxlen >= 0) {
		epctl = (epctl & 0xffff0000) | OXU210_EP_RX_EN | OXU210_EP_RX_TOG_RESET | OXU210_SET_RX_TYPE(in_type);
		OXU210HP_OTG_WR(OXU210_ENDPT_PAIRCTRL(ep), epctl);
	}
	epctl = OXU210HP_OTG_RD(OXU210_ENDPT_PAIRCTRL(ep));
	//device_printf(sc->sc_dev, "   ep %d epctl = %08x\n", ep, epctl);

  usbdev_dbg_list_counts (sc, 25, "%d:%s", ep, in_maxlen < 0 ? "disable" : "enable");
}

void
usbdev_set_ep_disable(usbdev_softc_t* sc, uint8_t ep)
{
  usbdev_set_ep_enable(sc, ep, -1, 0, -1, 0);
}

void
usbdev_set_ep_disable_all(usbdev_softc_t* sc)
{
  int ep;
  for (ep = 1; ep < (USB_EP_MAX/2/2); ++ep)
    usbdev_set_ep_disable(sc, ep);
}

// Set device address
void 
usbdev_set_address(usbdev_softc_t* sc, uint8_t addr) 
{
	OXU210HP_OTG_WR(OXU210_DEVADDR, OXU210_SET_DEV_ADDR(addr) | OXU210_ADDR_ADV_TRIG);
}

// Queue a PTD on a given endpoint queue
usb_error_t
usbdev_queue_ptd(usbdev_softc_t* sc, uint8_t ep_idx, oxu210_ptd_t *ptd)
{
	const uint32_t ep_bit = 1<<OXU210_EP_IDX_TO_BIT(ep_idx);
	uint32_t prime;
	uint32_t stat;
	oxu210_dqh_t *dqh;

  DPRINTFN(12, "ep=%d ptd=%p len=%d\n", ep_idx, ptd, ptd->len);

	dqh = &sc->sc_dqh[ep_idx];

	do {
		oxu210_ptd_t *tail;
		// Just read the ptd list directly from the hardware next pointers
		// This would need to change if our addresses did not match hardware bus address
		tail = (oxu210_ptd_t *)dqh->dqh_ptd.ptd_next;

		// Empty transfer list, just place on the head
		if((uint32_t)tail & 1) {
			dqh->dqh_ptd.ptd_next = ptd->ptd_self;
			dqh->dqh_ptd.ptd_status = 0;

			// Prime the endpoint
			OXU210HP_OTG_WR(OXU210_ENDPT_PRIME, ep_bit);

			// Wait for ptd to be accepted
			do {
				prime = OXU210HP_OTG_RD(OXU210_ENDPT_PRIME);
				stat = OXU210HP_OTG_RD(OXU210_ENDPT_STAT);
			} while(!stat && prime);

			if(!(stat | prime)) {
				DPRINTF("couldn't prime transfer\n");
				usbdev_dbg_print_dqh(dqh, ep_idx);
				usbdev_dbg_print_ptd(ptd);
				dqh->dqh_ptd.ptd_next = dtohc32(sc, OXU210_LINK_TERMINATE);
				return USB_ERR_IOERROR;
			}

			break;
	
		// Transfers queued, place this transfer at the end of the list
		} else {
			oxu210_ptd_t *nptd = tail;
			while(!((uint32_t)nptd & 1)) {
				if(tail == ptd) {
					device_printf(sc->sc_dev, "ptd queueing loop detected!\n");
					oxu210_halt();
				}
				tail = nptd;
				nptd = (oxu210_ptd_t *)tail->ptd.ptd_next;
			}

			tail->ptd.ptd_next = ptd->ptd_self;

			// If prime is set then we are golden, the controller will get to us eventually
			if(OXU210HP_OTG_RD(OXU210_ENDPT_PRIME) & ep_bit) {
				break;
			}

			do {
				// Arm descriptor tripwire and re-read stat until we get a good read
				OXU210HP_OTG_WR(OXU210_USBCMD, sc->sc_cmd | OXU210_CMD_AT);
				stat = OXU210HP_OTG_RD(OXU210_ENDPT_STAT);
				if(OXU210HP_OTG_RD(OXU210_USBCMD) & OXU210_CMD_AT)
					break;
			} while(1);

			// Disarm descriptor tripwire, we read stat OK
			OXU210HP_OTG_WR(OXU210_USBCMD, sc->sc_cmd);

			// If stat indicates a transfer is accepted, we are done otherwise restart
			if(stat & ep_bit)
				break;
		}
	} while(1);

	TAILQ_INSERT_TAIL(&dqh->ptd_list, ptd, entry);

  usbdev_dbg_list_counts(sc, 26, "queueing");
  
	return 0;
}

// Queue USB transfer
usb_error_t
usbdev_queue_xfer(usbdev_softc_t* sc, uint8_t ep, const uint8_t *txbuf, uint16_t txlen)
{
	oxu210_ptd_t *ptd;

	// Take a free ptd off the list
	ptd = usbdev_alloc_ptd(sc, txlen);
	USB_ASSERT(ptd, ("Unable to allocate a PTD\n"));
	if(!ptd)
  {
    usbdev_dbg_list_counts(sc, 1, "no mem");
		return USB_ERR_NOMEM;
  }
  
	// Copy data in to buffer if required
	if(OXU210_EP_IDX_IS_IN(ep) && txbuf && txlen)
		memcpy(ptd->buf_ptr, txbuf, txlen);

	return usbdev_queue_ptd(sc, ep, ptd);
}
// Interrupt processing
static void
usbdev_interrupt(usbdev_softc_t* sc)
{
	uint32_t complete;
	static uint32_t sbuf[2];
	usb_error_t err = 0;
//	int n;
	int restarted = 0;

//	USB_BUS_LOCK(&sc->sc_bus);

	dbg_port_leds_off(1<<7);

	// Fatal error, flush endpoints and reset
	if(sc->sc_status & EHCI_STS_HSE) {
		device_printf(sc->sc_dev, "unrecoverable error, restarting controller\n");
		usbdev_free_all_ptds(sc);
		restarted = 1;
		err = usbdev_init(sc);
		if (err) {
			device_printf(sc->sc_dev, "restart error, halting\n");
			oxu210_halt();
		}

		// Ignore any further interrupt status as we have just reset controller
		return;
	}

	// USB bus reset
	if(sc->sc_status & OXU210_STS_UR) {
    usbdev_dispatch_periph_event (sc, EVENT_RESET, 0);

		// Clear pending setup and I/O transfers
		complete = OXU210HP_OTG_RD(OXU210_ENDPT_SETUPSTAT);
		OXU210HP_OTG_WR(OXU210_ENDPT_SETUPSTAT, complete);
		complete = OXU210HP_OTG_RD(OXU210_ENDPT_COMPLETE);
		OXU210HP_OTG_WR(OXU210_ENDPT_COMPLETE, complete);

		complete = OXU210HP_OTG_RD(OXU210_ENDPT_COMPLETE);

		// Clear primed transfers
		do {
			complete = OXU210HP_OTG_RD(OXU210_ENDPT_PRIME);
		} while(complete);

		OXU210HP_OTG_WR(OXU210_ENDPT_FLUSH, (uint32_t)-1);

		usbdev_free_all_ptds(sc);

		uint32_t portsc = OXU210HP_OTG_RD(OXU210_PORTSC);
		if((portsc & OXU210_PORT_RESET) == 0) {
			device_printf(sc->sc_dev, "missed reset window, restarting controller\n");
			restarted = 1;
			err = usbdev_init(sc);
			if (err) {
				device_printf(sc->sc_dev, "restart error, halting\n");
				oxu210_halt();
			}

			// Ignore any further interrupt status as we have just reset controller
			return;

		}

		DPRINTFN(20, "reset\n");
    usbdev_dbg_list_counts (sc, 26, "int:reset");
	}

	{
		// USB suspend
		if((sc->sc_status & OXU210_STS_SU) != (sc->sc_oldstatus & OXU210_STS_SU)) {
      usbdev_dispatch_periph_event (sc, EVENT_SUSPEND,
                                    (sc->sc_status & OXU210_STS_SU) ? 1 : 0);
		}

		// Port change detect
		if(sc->sc_status & EHCI_STS_PCD) {
			uint32_t portsc = OXU210HP_OTG_RD(OXU210_PORTSC);
      usbdev_dispatch_periph_event (sc, EVENT_CONNECT,
                                    OXU210_GET_PORT_SPEED(portsc));
		}

		// Transfer complete (OK)
		if(sc->sc_status & EHCI_STS_INT) {

			DPRINTFN(9, "s = %08lx\n", sc->sc_status);
			// Setup transfers
			complete = OXU210HP_OTG_RD(OXU210_ENDPT_SETUPSTAT);
			if(complete) {
				int ep;

				if(complete & OXU210_EP_IN_BIT(0))
					DPRINTFN(20, "setup = %08lx\n", complete);

				// Check all the OUT endpoints for setup packets
				for(ep=0; ep<OXU210_EP_PAIR_COUNT; ++ep) {
					uint32_t ep_bit = OXU210_EP_OUT_BIT(ep);
					if(complete & ep_bit) {
						oxu210_dqh_t *dqh = &sc->sc_dqh[OXU210_EP_OUT_IDX(ep)];

redo_setup:
						// Clear any existing setup response
						usbdev_flush_and_clear_endpoint(sc, OXU210_EP_IN_IDX(ep));
						usbdev_flush_and_clear_endpoint(sc, OXU210_EP_OUT_IDX(ep));

						do {
							// Arm setup trigger
							OXU210HP_OTG_WR(OXU210_USBCMD, sc->sc_cmd | OXU210_CMD_ST);

							// Read setup data
							sbuf[0] = hc32tod(sc, dqh->dqh_setup[0]);
							sbuf[1] = hc32tod(sc, dqh->dqh_setup[1]);

							// Retry until setup trigger is unchanged
						} while(!OXU210HP_OTG_RD(OXU210_USBCMD) & OXU210_CMD_ST);

						// Disarm setup trigger
						OXU210HP_OTG_WR(OXU210_USBCMD, sc->sc_cmd);

						// Acknowledge setup
						OXU210HP_OTG_WR(OXU210_ENDPT_SETUPSTAT, ep_bit);
						do {
//							OXU210HP_OTG_WR(OXU210_ENDPT_SETUPSTAT, ep_bit);
						} while(OXU210HP_OTG_RD(OXU210_ENDPT_SETUPSTAT) & ep_bit);

						if(OXU210HP_OTG_RD(OXU210_ENDPT_SETUPSTAT) & ep_bit) {
							device_printf(sc->sc_dev, "timeout acknowledging setup packet\n");
							goto redo_setup;
//							oxu210_halt();
						}

						// Handle setup response
            usbdev_dispatch_periph_setup (sc, ep, (usb_device_request_t*)&sbuf[0]);

						// Check if a new setup packet has been received and flush any response
						if(OXU210HP_OTG_RD(OXU210_ENDPT_SETUPSTAT) & ep_bit)
							goto redo_setup;
					}
				}
			}

			DPRINTFN(21, "setup = %08lx\n", complete);

			// Completed I/O transfers
			complete = OXU210HP_OTG_RD(OXU210_ENDPT_COMPLETE);
			if(complete) {
				int n;

				//if(complete & OXU210_EP_IN_BIT(1))
					DPRINTFN(9, "complete = %08lx\n", complete);

				for(n=0; n<OXU210_EP_COUNT; ++n) {
					uint32_t ep_bit = 1<<n;
					if(complete & ep_bit) {
						uint8_t ep_idx = OXU210_EP_BIT_TO_IDX(n);
						oxu210_dqh_t *dqh = &sc->sc_dqh[ep_idx];
						oxu210_ptd_t *ptd, *nptd;

						DPRINTFN(9, "ep = %d, idx = %d\n", n, ep_idx);

						// Acknowledge complete transfers
						OXU210HP_OTG_WR(OXU210_ENDPT_COMPLETE, ep_bit);

						// Handle any completed transfers
						TAILQ_FOREACH_SAFE(ptd, &dqh->ptd_list, entry, nptd) {
							if((OXU210_PTD_GET_STATUS(ptd->ptd.ptd_status) & OXU210_PTD_ACTIVE) == 0) {
								TAILQ_REMOVE(&dqh->ptd_list, ptd, entry);
                usbdev_dispatch_periph_complete (sc, ep_idx, ptd, STATUS_COMPLETE);
							}
						}

						// Reset status in dqh
						if(OXU210_PTD_GET_STATUS(dqh->dqh_ptd.ptd_status) & 
						   (OXU210_PTD_HALTED | OXU210_PTD_BUFERR | OXU210_PTD_TRANS))
						{
							dqh->dqh_ptd.ptd_status = 0;
						}
					}
				}
			}
		}
	}

	sc->sc_oldstatus = sc->sc_status;
//	USB_BUS_UNLOCK(&sc->sc_bus);
}

// ISR
static void
usbdev_interrupt_low (void* ctx)
{
	usbdev_softc_t* sc = ctx;
	uint32_t      status, istatus;
	status = OXU210HP_OTG_RD(OXU210_USBSTS);
	istatus = OXU210_STS_INTRS(status);
	if(istatus != status)
		DPRINTFN(22, "sts %08lx != ists %08lx\n", status, istatus);
	if(istatus) {
		OXU210HP_OTG_WR(OXU210_USBSTS, istatus);
		sc->sc_status = istatus;
    #if EHCI_OXU_DEBUG_LED
		  dbg_port_leds_on(1<<7);
		#endif
		usbdev_interrupt(sc);
	}
}

static void
usbdev_setup_data_structures(usbdev_softc_t *sc)
{
	struct usb_page_search buf_res;
	int i;

	// Setup endpoint queue head descriptors
	usbd_get_page(&sc->sc_hw.ep_dqh_pc, 0, &buf_res);
	sc->sc_dqe_base = dtohc32(sc, buf_res.physaddr);
	sc->sc_dqh = buf_res.buffer;
	for(i=0; i<OXU210_EP_COUNT; ++i) {
		oxu210_dqh_t *dqh = &sc->sc_dqh[i];

		//dqh->dqh_epcap = dtohc32(sc, OXU210_DQH_SET_MAXLEN(x) | OXU210_DQH_IOS);
		if (i == OXU210_EP_OUT_IDX(USB_CONTROL_ENDPOINT) || i == OXU210_EP_IN_IDX(USB_CONTROL_ENDPOINT)) {
			dqh->dqh_epcap = dtohc32(sc, OXU210_DQH_SET_MAXLEN(OXU210_PTD_BUFSIZE) | OXU210_DQH_IOS);
		} else {
			dqh->dqh_epcap = 0;
		}
		dqh->dqh_curptd = 0;
		dqh->dqh_ptd.ptd_next = dtohc32(sc, OXU210_LINK_TERMINATE);
		dqh->dqh_ptd.ptd_status = dtohc32(sc, 0);

//		sc->sc_dqe[i].dqh = dqh;
		//sc->sc_ep_dqh[.].page_cache = sc->sc_hw.ep_dqh_pc;
		TAILQ_INIT(&sc->sc_dqh[i].ptd_list);
	}

	// Setup device transfer descriptors
	for(i=0; i<OXU210_NUM_PTDS; ++i) {
		oxu210_ptd_t *ptd;

		usbd_get_page(sc->sc_hw.ep_ptd_pc + i, 0, &buf_res);

		ptd = buf_res.buffer;

		/* initialize page cache pointer */

		ptd->page_cache = sc->sc_hw.ep_ptd_pc + i;

		ptd->ptd.ptd_next = dtohc32(sc, OXU210_LINK_TERMINATE);
		ptd->ptd.ptd_status = dtohc32(sc, OXU210_PTD_HALTED);
		ptd->ptd_self = dtohc32(sc, buf_res.physaddr);

		// Load fixed buffer into PTD buffer list
		usbd_get_page(sc->sc_hw.ep_buf_pc + i, 0, &buf_res);
		ptd->buf_size = OXU210_PTD_BUFSIZE;
		ptd->buf_ptr = buf_res.buffer;
		ptd->ptd.ptd_buffer[0] = dtohc32(sc, buf_res.physaddr);
		ptd->buf_page_cache = sc->sc_hw.ep_buf_pc + i;

		// Place on free list
		TAILQ_INSERT_TAIL(&sc->ptd_free, ptd, entry);
	}
}

static usb_error_t
usbdev_init(usbdev_softc_t *sc)
{
	uint32_t hcr;
	usb_error_t err = 0;
	int i;

	DPRINTFN (12, "init\n");

	/* Reset the controller */
	DPRINTFN (12, "%s: resetting\n", device_get_nameunit(sc->sc_dev));

	err = usbdev_reset(sc);
	if (err) {
		device_printf(sc->sc_dev, "reset timeout\n");
		return(err);
	}

	sc->sc_intrs = (OXU210_INTR_FE | OXU210_INTR_RE | EHCI_INTR_HSEE |
                  EHCI_INTR_PCIE | EHCI_INTR_UEIE | EHCI_INTR_UIE);

	uint32_t portsc = OXU210HP_OTG_RD(OXU210_PORTSC);
	OXU210HP_OTG_WR(OXU210_PORTSC, portsc | OXU210_FORCE_FULL_SPEED);

	/* flush all cache into memory */

	usbdev_mem_flush_all(sc, &usbdev_iterate_hw_softc);

	/* setup async list pointer */
	OXU210HP_OTG_WR(OXU210_EPLISTADDR, sc->sc_dqe_base);

	/* enable interrupts */
	OXU210HP_OTG_WR(OXU210_USBINTR, sc->sc_intrs);

	/* turn on controller */
	sc->sc_cmd =
		EHCI_CMD_ITC_1 |		 /* 1 microframes interrupt delay */
		EHCI_CMD_RS;
	OXU210HP_OTG_WR(OXU210_USBCMD, sc->sc_cmd);

	/* Take over port ownership */
//	OXU210HP_OTG_WR(0x40+ EHCI_CONFIGFLAG, EHCI_CONF_CF);

	for(i=0; i<100; i++) {
		usb_pause_mtx(NULL, hz / 1000);
		hcr = OXU210HP_OTG_RD(OXU210_USBSTS) & EHCI_STS_HCH;
		if (!hcr) {
			break;
		}
	}
	if (hcr) {
		device_printf(sc->sc_dev, "run timeout\n");
		return(USB_ERR_IOERROR);
	} else
		device_printf(sc->sc_dev, "running\n");

	if (!err) {
//		OXU210HP_HOSTIF_WR (R_ChipIRQEn_Clr, 0xffff);
//		OXU210HP_HOSTIF_WR (R_ChipIRQEn_Set, ChipIRQEn_OE);

		usbdev_interrupt_low(sc);
	}

	return(err);
}

int
usbdev_probe(device_t self)
{
	return(BUS_PROBE_DEFAULT);
}

int usbdev_detach(device_t self);

int
usbdev_attach(device_t self)
{
  usbdev_softc_t *sc = device_get_softc(self);
	int err;

	DPRINTFN (10, "sc = %p\n", sc);
	device_set_desc(self, OXU210HP_USBDEV_STR);

	/* initialise some bus fields */
	sc->sc_io_tag = 0U;
	sc->sc_io_hdl = OXU210HP_IF_0_BASE + OXU210_USB_OTG_OFST;
	sc->sc_io_size = 0x00020000;
	sc->sc_dev = self;

	sc->sc_flags = EHCI_SCFLG_SETMODE;
  
	sc->handlers = device_get_ivars(self);;
  
	/* get all DMA memory */
	if (usbdev_mem_alloc_all(sc,
							 USB_GET_DMA_TAG(self), &usbdev_iterate_hw_softc)) {
		return(ENOMEM);
	}

	uint32_t version = OXU210_GET_DCIVERSION(OXU210HP_OTG_RD(OXU210_DCIVERSION));
	device_printf(sc->sc_dev, "DCI version %lx.%lx\n",
				  version >> 8, version & 0xff);

	version = OXU210HP_OTG_RD(OXU210_DCCPARAMS);
	if (version & OXU210_DCCPARAMS_HC)
		device_printf(sc->sc_dev, "Supports host\n");
	if (version & OXU210_DCCPARAMS_DC)
		device_printf(sc->sc_dev, "Supports device (%lu endpoints)\n",
                  OXU210_GET_DCCPARAMS_DEN(version));

	/* disable interrupts */
	OXU210HP_OTG_WR(OXU210_USBINTR, 0);

	err = oxu210_intr_attach (oxu210_intr_otg,
							  usbdev_interrupt_low,
							  sc);
	if (err) {
	  device_printf(self, "Interrupt attach error\n");
	  goto error;
	}

	usbdev_setup_data_structures(sc);

	err = usbdev_init(sc);
	if (err) {
		device_printf(self, "USB peripheral init failed err=%d\n", err);
		goto error;
	}

	return(0);

error:
	usbdev_detach(self);
	return(ENXIO);

}

int
usbdev_detach(device_t self)
{
	usbdev_softc_t *sc = device_get_softc(self);

  usbdev_reset (sc);

	oxu210_intr_detach (oxu210_intr_otg);

	usbdev_mem_free_all(sc, &usbdev_iterate_hw_softc);

	return(0);
}

static device_method_t usbdev_methods [] = {
	/* Device interface */
	DEVMETHOD(device_probe,    usbdev_probe),
	DEVMETHOD(device_attach,   usbdev_attach),
	DEVMETHOD(device_detach,   usbdev_detach),
	DEVMETHOD(device_shutdown, bus_generic_shutdown),
	DEVMETHOD(device_suspend,  bus_generic_suspend),
	DEVMETHOD(device_resume,   bus_generic_resume),

	{ 0, 0}
};

static driver_t usbdev_driver = {
	.name = "usbdev",
	.methods = usbdev_methods,
	.size =   sizeof(usbdev_softc_t),
};

static devclass_t usbdev_devclass;

DRIVER_MODULE(usbdev, pdev, usbdev_driver, usbdev_devclass, 0, 0);
MODULE_DEPEND(usbdev, pdev, 1, 1, 1);
MODULE_VERSION(usbdev, 1);
