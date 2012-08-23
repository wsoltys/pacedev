#ifndef _PDEV_H_
#define	_PDEV_H_

/*
 * Forward decl.
 */
struct periph;
typedef struct periph periph_t;
struct pdev_down_softc;

#include "periph.h"
#include "usbdev_oxu210.h"

/**
 * The down stream device data.
 */
typedef struct {
  struct pdev_down_softc* sc;
  struct mtx*             mtx;
  struct usb_device*      udev;
  uint8_t	                iface_index;
  struct usb_xfer*        xfers[USB_EP_MAX];
  int                     endpoints;
  struct usb_config*      configs;
} periph_down_t;

/**
 * The up stream device data.
 */
typedef struct {
  device_t dev;
	void* sc;
  uint8_t dev_config;
} periph_up_t;

/*
 * End Point filter function responses.
 */
typedef enum {
  periph_ep_send,   /*<< Send the filtered data to the other side of the pipe. */
  periph_ep_drop    /*<< Drop the filtered data. */
} periph_ep_resp_t;

/*
 * Forward decl.
 */
struct periph_ep_ctrl;
typedef struct periph_ep_ctrl periph_ep_ctrl_t;

/**
 * End point data.
 */
typedef struct {
  uint8_t* data; /*<< End point data. The user can modify. */
  int      len;  /*<< Length of valid data in the data array. The user can
                  *   modify. */
} periph_ep_data_t;

/*
 * End Point filter function. The endpoint control is locked when called.
 */
typedef periph_ep_resp_t (*periph_ep_filter_handler_t) (periph_t*         per,
                                                        periph_ep_ctrl_t* epc,
                                                        periph_ep_data_t* epd,
                                                        void*             user);

typedef struct {
  periph_ep_filter_handler_t handler; /*<< The handler. */
  void*                      user;    /*<< The user data passed with the handler. */
} periph_ep_filter_t;

/**
 * End point control.
 */
struct periph_ep_ctrl {
  uint8_t    endpoint;       /*<< The endpoint number. Do not change. */
  uint8_t    type;           /*<< The type of the endpoint. Do not change. */
  uint8_t    direction;      /*<< The end point's directory. Relative to
                              *   upstream. */
  uint8_t    max_size;       /*<< The maxium packet size. The size of the
                              *   buffer. */
  struct mtx lock;           /*<< The endpoint control lock. */
  uint8_t*   buffer;         /*<< End point buffer used in with the end point
                              *   data. */
  int        xfer_len;       /*<< If >0 it is the length to send. */
  periph_ep_filter_t filter; /*<< User's filter. */
};

#define PERIPH_THREAD_STOPPED  (0)
#define PERIPH_THREAD_RUNNING  (1)
#define PERIPH_THREAD_STOPPING (2)

struct periph {
  /*
   * The name of the periperal.
   */
	char	*name;

  /*
   * The downstream device.
   */
  periph_down_t down;

  /*
   * The upstream device.
   */
  periph_up_t up;

  /*
   * End Point Controls.
   */
  periph_ep_ctrl_t ep_ctrl[USB_EP_MAX];

  /*
   * Down stream sending thread.
   */
  os_thread_t downstream_thread;

  /*
   * Down stream thread running.
   */
  volatile int downstream_state;

  /*
   * Event to signal the downstream thread.
   */
  os_events_t downstream_wait;

  /*
   * The USB device handlers.
   */
  usbdev_handlers_t udev_handlers;
};

/**
 * PDEV events
 */
typedef enum pdev_event {
	PDEV_EVENT_ATTACH,
	PDEV_EVENT_DETACH,
	PDEV_EVENT_CONFIGURE,
	PDEV_EVENT_RESET,
	PDEV_EVENT_RESUME,
	PDEV_EVENT_SUSPEND,
} pdev_event_t;

/**
 * PDEV handlers.
 *
 * @param event The reason for the event call being made.
 * @param per The peripheral the event is for.
 * @param user The user pointer used when hooking the function..
 */
typedef void (*pdev_device_event_handler_t) (pdev_event_t event, 
                                             periph_t*    per,
                                             void*        user);
typedef struct {
  pdev_device_event_handler_t handler;
  void*                       user;
} pdev_device_event_t;

/**
 * The down stream driver software control block.
 */
struct pdev_down_softc {
  struct usb_fifo_sc  sc_fifo;
  struct mtx          sc_mtx;
  struct usb_callout  sc_callout;
  struct usb_device*  sc_udev;
  periph_t*           per;
  uint32_t            sc_unit;
  uint32_t            sc_freq;
  uint8_t             sc_name[16];
  pdev_device_event_t next_device_event;
};

/**
 * Print with the device name at the start.
 */
int pdev_device_printf (periph_t* per, const char * fmt, ...);

/**
 * Invoke the event handler.
 */
static inline void
pdev_device_invoke_event_handler (pdev_device_event_t* eh,
                                  pdev_event_t         event, 
                                  periph_t*            per)
{
  if (eh->handler)
    eh->handler (event, per, eh->user);
}

/**
 * Hook the event handler, save away the result and invoke so chains can
 * be made.
 */
pdev_device_event_t pdev_device_event_hook (pdev_device_event_t* event);

/**
 * Check a peripheral device against.
 */
int pdev_check_vendor_product (periph_t* per, uint16_t vendor, uint16_t product);

/**
 * Decode the end point index to an end point and direction.
 */
void pdev_ep_decode (uint8_t endpointno, uint8_t* ep, uint8_t* ep_dir);

/**
 * Compute an endpoint index from the end point and direction.
 */
int pdev_ep_index (uint8_t ep, uint8_t ep_dir);

/**
 * Return the end point and direction given an end point index.
 */
void pdev_ep_deindex (int ep_index, uint8_t* ep, uint8_t* ep_dir);

/**
 * Hook an end point filter.
 */
periph_ep_filter_t pdev_device_ep_filter_hook (periph_t*           per,
                                               uint8_t             ep,
                                               uint8_t             dir,
                                               periph_ep_filter_t* filter);

/**
 * Obtain the end point control.
 */
periph_ep_ctrl_t* pdev_ep_control_obtain (periph_t* per, 
                                          uint8_t   ep,
                                          uint8_t   dir);

/**
 * Release the end point control.
 */
void pdev_ep_control_release (periph_ep_ctrl_t* epc);

/**
 * Up stream device layer attach.
 */
int pdev_attach_up_device (periph_t* per);
int pdev_detach_up_device (periph_t* per);

/**
 * The down stream device attach and detach.
 */
int pdev_attach_down_device (device_t dev);
int pdev_detach_down_device (device_t dev);

#endif
