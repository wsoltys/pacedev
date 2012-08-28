#ifdef PACE_HAS_AUDIO

#include "usb.h"
#include "usbdi.h"
#include "usbdi_util.h"
#include "usbhid.h"

#include "uaudioreg.h"
#include "uaudio.h"

#define	USB_DEBUG_VAR audio_debug
#include "usb_debug.h"

#undef DPRINTF
#undef DPRINTFN
#define DPRINTF(format...)        printf (format);
#define DPRINTFN(lvl, format...)  printf (format);

static int uaudio_default_rate = 0;		/* use rate list */
static int uaudio_default_bits = 32;
static int uaudio_default_channels = 0;		/* use default */

int	uaudio_debug = 1;

#define	UAUDIO_NFRAMES		64	/* must be factor of 8 due HS-USB */
#define	UAUDIO_NCHANBUFS        2	/* number of outstanding request */
#define	UAUDIO_RECURSE_LIMIT   24	/* rounds */

#define	MAKE_WORD(h,l) (((h) << 8) | (l))
#define	BIT_TEST(bm,bno) (((bm)[(bno) / 8] >> (7 - ((bno) % 8))) & 1)
#define	UAUDIO_MAX_CHAN(x) (x)

struct uaudio_chan {
	//struct pcmchan_caps pcm_cap;	/* capabilities */

	struct snd_dbuf *pcm_buf;
	const struct usb_config *usb_cfg;
	struct mtx *pcm_mtx;		/* lock protecting this structure */
	struct uaudio_softc *priv_sc;
	struct pcm_channel *pcm_ch;
	struct usb_xfer *xfer[UAUDIO_NCHANBUFS];
	const struct usb_audio_streaming_interface_descriptor *p_asid;
	const struct usb_audio_streaming_type1_descriptor *p_asf1d;
	const struct usb_audio_streaming_endpoint_descriptor *p_sed;
	const usb_endpoint_descriptor_audio_t *p_ed1;
	const usb_endpoint_descriptor_audio_t *p_ed2;
	const struct uaudio_format *p_fmt;

	uint8_t *buf;			/* pointer to buffer */
	uint8_t *start;			/* upper layer buffer start */
	uint8_t *end;			/* upper layer buffer end */
	uint8_t *cur;			/* current position in upper layer
					 * buffer */

	uint32_t intr_size;		/* in bytes */
	uint32_t intr_frames;		/* in units */
	uint32_t sample_rate;
	uint32_t frames_per_second;
	uint32_t sample_rem;
	uint32_t sample_curr;

	uint32_t format;
	uint32_t pcm_format[2];

	uint16_t bytes_per_frame[2];

	uint16_t sample_size;

	uint8_t	valid;
	uint8_t	iface_index;
	uint8_t	iface_alt_index;
};

struct uaudio_softc {
	struct sbuf sc_sndstat;
	//struct sndcard_func sc_sndcard_func;
	struct uaudio_chan sc_rec_chan;
	struct uaudio_chan sc_play_chan;
	//struct umidi_chan sc_midi_chan;

	struct usb_device *sc_udev;
	struct usb_xfer *sc_mixer_xfer[1];
	struct uaudio_mixer_node *sc_mixer_root;
	struct uaudio_mixer_node *sc_mixer_curr;

	uint32_t sc_mix_info;
	uint32_t sc_recsrc_info;

	uint16_t sc_audio_rev;
	uint16_t sc_mixer_count;

	uint8_t	sc_sndstat_valid;
	uint8_t	sc_mixer_iface_index;
	uint8_t	sc_mixer_iface_no;
	uint8_t	sc_mixer_chan;
	uint8_t	sc_pcm_registered:1;
	uint8_t	sc_mixer_init:1;
	uint8_t	sc_uq_audio_swap_lr:1;
	uint8_t	sc_uq_au_inp_async:1;
	uint8_t	sc_uq_au_no_xu:1;
	uint8_t	sc_uq_bad_adc:1;
	uint8_t	sc_uq_au_vendor_class:1;
};

struct uaudio_format {
	uint16_t wFormat;
	uint8_t	bPrecision;
	uint32_t freebsd_fmt;
	const char *description;
};

#define AFMT_MU_LAW	0x00000001	/* Logarithmic mu-law */
#define AFMT_A_LAW	0x00000002	/* Logarithmic A-law */
#define AFMT_U8		0x00000008	/* Unsigned 8-bit */
#define AFMT_S16_LE	0x00000010	/* Little endian signed 16-bit */
#define AFMT_S16_BE	0x00000020	/* Big endian signed 16-bit */
#define AFMT_S8		0x00000040	/* Signed 8-bit */
#define AFMT_U16_LE	0x00000080	/* Little endian unsigned 16-bit */
#define AFMT_U16_BE	0x00000100	/* Big endian unsigned 16-bit */

#define AFMT_S32_LE	0x00001000	/* Little endian signed 32-bit */
#define AFMT_S32_BE	0x00002000	/* Big endian signed 32-bit */
#define AFMT_U32_LE	0x00004000	/* Little endian unsigned 32-bit */
#define AFMT_U32_BE	0x00008000	/* Big endian unsigned 32-bit */
#define AFMT_S24_LE	0x00010000	/* Little endian signed 24-bit */
#define AFMT_S24_BE	0x00020000	/* Big endian signed 24-bit */
#define AFMT_U24_LE	0x00040000	/* Little endian unsigned 24-bit */
#define AFMT_U24_BE	0x00080000	/* Big endian unsigned 24-bit */
#define AFMT_STEREO	0x10000000	/* can do/want stereo	*/

static const struct uaudio_format uaudio_formats[] = {

	{UA_FMT_PCM8, 8, AFMT_U8, "8-bit U-LE PCM"},
	{UA_FMT_PCM8, 16, AFMT_U16_LE, "16-bit U-LE PCM"},
	{UA_FMT_PCM8, 24, AFMT_U24_LE, "24-bit U-LE PCM"},
	{UA_FMT_PCM8, 32, AFMT_U32_LE, "32-bit U-LE PCM"},

	{UA_FMT_PCM, 8, AFMT_S8, "8-bit S-LE PCM"},
	{UA_FMT_PCM, 16, AFMT_S16_LE, "16-bit S-LE PCM"},
	{UA_FMT_PCM, 24, AFMT_S24_LE, "24-bit S-LE PCM"},
	{UA_FMT_PCM, 32, AFMT_S32_LE, "32-bit S-LE PCM"},

	{UA_FMT_ALAW, 8, AFMT_A_LAW, "8-bit A-Law"},
	{UA_FMT_MULAW, 8, AFMT_MU_LAW, "8-bit mu-Law"},

	{0, 0, 0, NULL}
};

/* prototypes */

static device_probe_t uaudio_probe;
static device_attach_t uaudio_attach;
static device_detach_t uaudio_detach;

static void
uaudio_chan_fill_info_sub(struct uaudio_softc *sc, struct usb_device *udev,
    uint32_t rate, uint8_t channels, uint8_t bit_resolution);
static void
uaudio_chan_fill_info(struct uaudio_softc *sc, struct usb_device *udev);
static void
uaudio_chan_play_callback(struct usb_xfer *xfer, usb_error_t error);

static const struct usb_config
	uaudio_cfg_play[UAUDIO_NCHANBUFS] = {
	[0] = {
		.type = UE_ISOCHRONOUS,
		.endpoint = UE_ADDR_ANY,
		.direction = UE_DIR_OUT,
		.bufsize = 0,	/* use "wMaxPacketSize * frames" */
		.frames = UAUDIO_NFRAMES,
		.flags = {.short_xfer_ok = 1,},
		.callback = &uaudio_chan_play_callback,
	},

	[1] = {
		.type = UE_ISOCHRONOUS,
		.endpoint = UE_ADDR_ANY,
		.direction = UE_DIR_OUT,
		.bufsize = 0,	/* use "wMaxPacketSize * frames" */
		.frames = UAUDIO_NFRAMES,
		.flags = {.short_xfer_ok = 1,},
		.callback = &uaudio_chan_play_callback,
	},
};

static int
uaudio_probe(device_t dev)
{
	struct usb_attach_arg *uaa = device_get_ivars(dev);

	if (uaa->usb_mode != USB_MODE_HOST)
		return (ENXIO);

	/* lookup non-standard device */

	if (uaa->info.bInterfaceClass != UICLASS_AUDIO)
			return (ENXIO);

  //printf ("bDeviceClass = %d\n", uaa->info.bDeviceClass);
  //printf ("bDeviceSubClass = %d\n", uaa->info.bDeviceSubClass);
  //printf ("bDeviceProtocol = %d\n", uaa->info.bDeviceProtocol);
  //printf ("bInterfaceClass = %d\n", uaa->info.bInterfaceClass);
  //printf ("bInterfaceSubClass = %d\n", uaa->info.bInterfaceSubClass);
  //printf ("bInterfaceProtocol = %d\n", uaa->info.bInterfaceProtocol);
  //printf ("bIfaceIndex = %d\n", uaa->info.bIfaceIndex);
  //printf ("bIfaceNum = %d\n", uaa->info.bIfaceNum);
  //printf ("bConfigIndex = %d\n", uaa->info.bConfigIndex);
  //printf ("bConfigNum = %d\n", uaa->info.bConfigNum);
  //printf ("\n");

	/* check for AUDIO control interface */

	if (uaa->info.bInterfaceSubClass == UISUBCLASS_AUDIOCONTROL)
  {
    printf ("found: UISUBCLASS_AUDIOCONTROL\n");
		return (BUS_PROBE_GENERIC);
	}

	return (ENXIO);
}

void   *
uaudio_chan_init(struct uaudio_softc *sc, struct snd_dbuf *b,
    struct pcm_channel *c, int dir)
{
#if 0
	struct uaudio_chan *ch = ((dir == PCMDIR_PLAY) ?
	    &sc->sc_play_chan : &sc->sc_rec_chan);
	uint32_t buf_size;
	uint32_t frames;
	uint32_t format;
	uint16_t fps;
	uint8_t endpoint;
	uint8_t blocks;
	uint8_t iface_index;
	uint8_t alt_index;
	uint8_t fps_shift;
	usb_error_t err;

	fps = usbd_get_isoc_fps(sc->sc_udev);

	if (fps < 8000) {
		/* FULL speed USB */
		frames = 8;
	} else {
		/* HIGH speed USB */
		frames = UAUDIO_NFRAMES;
	}

	/* setup play/record format */

	ch->pcm_cap.fmtlist = ch->pcm_format;

	ch->pcm_format[0] = 0;
	ch->pcm_format[1] = 0;

	ch->pcm_cap.minspeed = ch->sample_rate;
	ch->pcm_cap.maxspeed = ch->sample_rate;

	/* setup mutex and PCM channel */

	ch->pcm_ch = c;
	ch->pcm_mtx = c->lock;

	format = ch->p_fmt->freebsd_fmt;

	switch (ch->p_asf1d->bNrChannels) {
	case 2:
		/* stereo */
		format = SND_FORMAT(format, 2, 0);
		break;
	case 1:
		/* mono */
		format = SND_FORMAT(format, 1, 0);
		break;
	default:
		/* surround and more */
		format = feeder_matrix_default_format(
		    SND_FORMAT(format, ch->p_asf1d->bNrChannels, 0));
		break;
	}

	ch->pcm_cap.fmtlist[0] = format;
	ch->pcm_cap.fmtlist[1] = 0;

	/* check if format is not supported */

	if (format == 0) {
		DPRINTF("The selected audio format is not supported\n");
		goto error;
	}

	/* set alternate interface corresponding to the mode */

	endpoint = ch->p_ed1->bEndpointAddress;
	iface_index = ch->iface_index;
	alt_index = ch->iface_alt_index;

	DPRINTF("endpoint=0x%02x, speed=%d, iface=%d alt=%d\n",
	    endpoint, ch->sample_rate, iface_index, alt_index);

	err = usbd_set_alt_interface_index(sc->sc_udev, iface_index, alt_index);
	if (err) {
		DPRINTF("setting of alternate index failed: %s!\n",
		    usbd_errstr(err));
		goto error;
	}
	usbd_set_parent_iface(sc->sc_udev, iface_index,
	    sc->sc_mixer_iface_index);

	/*
	 * Only set the sample rate if the channel reports that it
	 * supports the frequency control.
	 */
	if (ch->p_sed->bmAttributes & UA_SED_FREQ_CONTROL) {
		if (uaudio_set_speed(sc->sc_udev, endpoint, ch->sample_rate)) {
			/*
			 * If the endpoint is adaptive setting the speed may
			 * fail.
			 */
			DPRINTF("setting of sample rate failed! (continuing anyway)\n");
		}
	}
	if (usbd_transfer_setup(sc->sc_udev, &iface_index, ch->xfer,
	    ch->usb_cfg, UAUDIO_NCHANBUFS, ch, ch->pcm_mtx)) {
		DPRINTF("could not allocate USB transfers!\n");
		goto error;
	}

	fps_shift = usbd_xfer_get_fps_shift(ch->xfer[0]);

	/* down shift number of frames per second, if any */
	fps >>= fps_shift;
	frames >>= fps_shift;

	/* bytes per frame should not be zero */
	ch->bytes_per_frame[0] = ((ch->sample_rate / fps) * ch->sample_size);
	ch->bytes_per_frame[1] = (((ch->sample_rate + fps - 1) / fps) * ch->sample_size);

	/* setup data rate dithering, if any */
	ch->frames_per_second = fps;
	ch->sample_rem = ch->sample_rate % fps;
	ch->sample_curr = 0;
	ch->frames_per_second = fps;

	/* compute required buffer size */
	buf_size = (ch->bytes_per_frame[1] * frames);

	ch->intr_size = buf_size;
	ch->intr_frames = frames;

	DPRINTF("fps=%d sample_rem=%d\n", fps, ch->sample_rem);

	if (ch->intr_frames == 0) {
		DPRINTF("frame shift is too high!\n");
		goto error;
	}

	/* setup double buffering */
	buf_size *= 2;
	blocks = 2;

	ch->buf = malloc(buf_size, M_DEVBUF, M_WAITOK | M_ZERO);
	if (ch->buf == NULL)
		goto error;
	if (sndbuf_setup(b, ch->buf, buf_size) != 0)
		goto error;
	if (sndbuf_resize(b, blocks, ch->intr_size)) 
		goto error;

	ch->start = ch->buf;
	ch->end = ch->buf + buf_size;
	ch->cur = ch->buf;
	ch->pcm_buf = b;

	if (ch->pcm_mtx == NULL) {
		DPRINTF("ERROR: PCM channels does not have a mutex!\n");
		goto error;
	}

	return (ch);

error:
	uaudio_chan_free(ch);
	return (NULL);
	
#else
	struct uaudio_chan *ch = &sc->sc_play_chan;
	uint32_t buf_size;
	uint32_t frames;
	uint32_t format;
	uint16_t fps;
	uint8_t endpoint;
	uint8_t blocks;
	uint8_t iface_index;
	uint8_t alt_index;
	uint8_t fps_shift;
	usb_error_t err;

	fps = usbd_get_isoc_fps(sc->sc_udev);
	if (fps < 8000) {
		/* FULL speed USB */
		frames = 8;
	} else {
		/* HIGH speed USB */
		frames = UAUDIO_NFRAMES;
	}

	endpoint = ch->p_ed1->bEndpointAddress;
	iface_index = ch->iface_index;
	alt_index = ch->iface_alt_index;

	DPRINTF("endpoint=0x%02x, speed=%d, iface=%d alt=%d\n",
	    endpoint, ch->sample_rate, iface_index, alt_index);

	err = usbd_set_alt_interface_index(sc->sc_udev, iface_index, alt_index);
	if (err) {
		DPRINTF("setting of alternate index failed: %s!\n",
		    usbd_errstr(err));
		goto error;
	}

	fps_shift = usbd_xfer_get_fps_shift(ch->xfer[0]);

	/* down shift number of frames per second, if any */
	fps >>= fps_shift;
	frames >>= fps_shift;

	/* bytes per frame should not be zero */
	ch->bytes_per_frame[0] = ((ch->sample_rate / fps) * ch->sample_size);
	ch->bytes_per_frame[1] = (((ch->sample_rate + fps - 1) / fps) * ch->sample_size);

	/* setup data rate dithering, if any */
	ch->frames_per_second = fps;
	ch->sample_rem = ch->sample_rate % fps;
	ch->sample_curr = 0;
	ch->frames_per_second = fps;

	/* compute required buffer size */
	buf_size = (ch->bytes_per_frame[1] * frames);

	ch->intr_size = buf_size;
	ch->intr_frames = frames;

	DPRINTF("fps=%d sample_rem=%d\n", fps, ch->sample_rem);

	if (ch->intr_frames == 0) {
		DPRINTF("frame shift is too high!\n");
		goto error;
	}

	/* setup double buffering */
	buf_size *= 2;
	blocks = 2;

	ch->buf = malloc(buf_size, M_DEVBUF, M_WAITOK | M_ZERO);
	if (ch->buf == NULL)
		goto error;
#if 0
	if (sndbuf_setup(b, ch->buf, buf_size) != 0)
		goto error;
	if (sndbuf_resize(b, blocks, ch->intr_size)) 
		goto error;
#endif

	ch->start = ch->buf;
	ch->end = ch->buf + buf_size;
	ch->cur = ch->buf;
	ch->pcm_buf = b;

	if (ch->pcm_mtx == NULL) {
		DPRINTF("ERROR: PCM channels does not have a mutex!\n");
		goto error;
	}

	return (ch);

error:
  return (NULL);
#endif
}

static void
uaudio_chan_play_callback(struct usb_xfer *xfer, usb_error_t error)
{
	struct uaudio_chan *ch = usbd_xfer_softc(xfer);
	struct usb_page_cache *pc;
	uint32_t total;
	uint32_t blockcount;
	uint32_t n;
	uint32_t offset;
	int actlen;
	int sumlen;

	usbd_xfer_status(xfer, &actlen, &sumlen, NULL, NULL);

	if (ch->end == ch->start) {
		DPRINTF("no buffer!\n");
		return;
	}

	switch (USB_GET_STATE(xfer)) {
	case USB_ST_TRANSFERRED:
tr_transferred:
		if (actlen < sumlen) {
			DPRINTF("short transfer, "
			    "%d of %d bytes\n", actlen, sumlen);
		}
		// FIXME!!! chn_intr(ch->pcm_ch);

	case USB_ST_SETUP:
		if (ch->bytes_per_frame[1] > usbd_xfer_max_framelen(xfer)) {
			DPRINTF("bytes per transfer, %d, "
			    "exceeds maximum, %d!\n",
			    ch->bytes_per_frame[1],
			    usbd_xfer_max_framelen(xfer));
			break;
		}

		blockcount = ch->intr_frames;

		/* setup number of frames */
		usbd_xfer_set_frames(xfer, blockcount);

		/* reset total length */
		total = 0;

		/* setup frame lengths */
		for (n = 0; n != blockcount; n++) {
			ch->sample_curr += ch->sample_rem;
			if (ch->sample_curr >= ch->frames_per_second) {
				ch->sample_curr -= ch->frames_per_second;
				usbd_xfer_set_frame_len(xfer, n, ch->bytes_per_frame[1]);
				total += ch->bytes_per_frame[1];
			} else {
				usbd_xfer_set_frame_len(xfer, n, ch->bytes_per_frame[0]);
				total += ch->bytes_per_frame[0];
			}
		}

		DPRINTFN(6, "transfer %d bytes\n", total);

		offset = 0;

		pc = usbd_xfer_get_frame(xfer, 0);
		while (total > 0) {

			n = (ch->end - ch->cur);
			if (n > total) {
				n = total;
			}
			usbd_copy_in(pc, offset, ch->cur, n);

			total -= n;
			ch->cur += n;
			offset += n;

			if (ch->cur >= ch->end) {
				ch->cur = ch->start;
			}
		}

		usbd_transfer_submit(xfer);
		break;

	default:			/* Error */
		if (error == USB_ERR_CANCELLED) {
			break;
		}
		goto tr_transferred;
	}
}

static void
uaudio_chan_fill_info_sub(struct uaudio_softc *sc, struct usb_device *udev,
    uint32_t rate, uint8_t channels, uint8_t bit_resolution)
{
	struct usb_descriptor *desc = NULL;
	const struct usb_audio_streaming_interface_descriptor *asid = NULL;
	const struct usb_audio_streaming_type1_descriptor *asf1d = NULL;
	const struct usb_audio_streaming_endpoint_descriptor *sed = NULL;
	usb_endpoint_descriptor_audio_t *ed1 = NULL;
	const usb_endpoint_descriptor_audio_t *ed2 = NULL;
	struct usb_config_descriptor *cd = usbd_get_config_descriptor(udev);
	struct usb_interface_descriptor *id;
	const struct uaudio_format *p_fmt;
	struct uaudio_chan *chan;
	uint16_t curidx = 0xFFFF;
	uint16_t lastidx = 0xFFFF;
	uint16_t alt_index = 0;
	uint16_t wFormat;
	uint8_t ep_dir;
	uint8_t bChannels;
	uint8_t bBitResolution;
	uint8_t x;
	uint8_t audio_if = 0;
	uint8_t uma_if_class;

	while ((desc = usb_desc_foreach(cd, desc))) {

		if ((desc->bDescriptorType == UDESC_INTERFACE) &&
		    (desc->bLength >= sizeof(*id))) {

			id = (void *)desc;

			if (id->bInterfaceNumber != lastidx) {
				lastidx = id->bInterfaceNumber;
				curidx++;
				alt_index = 0;

			} else {
				alt_index++;
			}

			uma_if_class =
			    ((id->bInterfaceClass == UICLASS_AUDIO) ||
			    ((id->bInterfaceClass == UICLASS_VENDOR) &&
			    (sc->sc_uq_au_vendor_class != 0)));

			if ((uma_if_class != 0) && (id->bInterfaceSubClass == UISUBCLASS_AUDIOSTREAM)) {
				audio_if = 1;
			} else {
				audio_if = 0;
			}

#ifdef HAS_MIDI_SUPPORT
			if ((uma_if_class != 0) &&
			    (id->bInterfaceSubClass == UISUBCLASS_MIDISTREAM)) {

				/*
				 * XXX could allow multiple MIDI interfaces
				 */

				if ((sc->sc_midi_chan.valid == 0) &&
				    usbd_get_iface(udev, curidx)) {
					sc->sc_midi_chan.iface_index = curidx;
					sc->sc_midi_chan.iface_alt_index = alt_index;
					sc->sc_midi_chan.valid = 1;
				}
			}
#endif
			asid = NULL;
			asf1d = NULL;
			ed1 = NULL;
			ed2 = NULL;
			sed = NULL;
		}
		if ((desc->bDescriptorType == UDESC_CS_INTERFACE) &&
		    (desc->bDescriptorSubtype == AS_GENERAL) &&
		    (desc->bLength >= sizeof(*asid))) {
			if (asid == NULL) {
				asid = (void *)desc;
			}
		}
		if ((desc->bDescriptorType == UDESC_CS_INTERFACE) &&
		    (desc->bDescriptorSubtype == FORMAT_TYPE) &&
		    (desc->bLength >= sizeof(*asf1d))) {
			if (asf1d == NULL) {
				asf1d = (void *)desc;
				if (asf1d->bFormatType != FORMAT_TYPE_I) {
					DPRINTFN(11, "ignored bFormatType = %d\n",
					    asf1d->bFormatType);
					asf1d = NULL;
					continue;
				}
				if (asf1d->bLength < (sizeof(*asf1d) +
				    ((asf1d->bSamFreqType == 0) ? 6 :
				    (asf1d->bSamFreqType * 3)))) {
					DPRINTFN(11, "'asf1d' descriptor is too short\n");
					asf1d = NULL;
					continue;
				}
			}
		}
		if ((desc->bDescriptorType == UDESC_ENDPOINT) &&
		    (desc->bLength >= UEP_MINSIZE)) {
			if (ed1 == NULL) {
				ed1 = (void *)desc;
				if (UE_GET_XFERTYPE(ed1->bmAttributes) != UE_ISOCHRONOUS) {
					ed1 = NULL;
				}
			}
		}
		if ((desc->bDescriptorType == UDESC_CS_ENDPOINT) &&
		    (desc->bDescriptorSubtype == AS_GENERAL) &&
		    (desc->bLength >= sizeof(*sed))) {
			if (sed == NULL) {
				sed = (void *)desc;
			}
		}
		if (audio_if && asid && asf1d && ed1 && sed) {

			ep_dir = UE_GET_DIR(ed1->bEndpointAddress);

			/* We ignore sync endpoint information until further. */

			wFormat = UGETW(asid->wFormatTag);
			bChannels = UAUDIO_MAX_CHAN(asf1d->bNrChannels);
			bBitResolution = asf1d->bBitResolution;

			if (asf1d->bSamFreqType == 0) {
				DPRINTFN(16, "Sample rate: %d-%dHz\n",
				    UA_SAMP_LO(asf1d), UA_SAMP_HI(asf1d));

				if ((rate >= UA_SAMP_LO(asf1d)) &&
				    (rate <= UA_SAMP_HI(asf1d))) {
					goto found_rate;
				}
			} else {

				for (x = 0; x < asf1d->bSamFreqType; x++) {
					DPRINTFN(16, "Sample rate = %dHz\n",
					    UA_GETSAMP(asf1d, x));

					if (rate == UA_GETSAMP(asf1d, x)) {
						goto found_rate;
					}
				}
			}

			audio_if = 0;
			continue;

	found_rate:

			for (p_fmt = uaudio_formats;
			    p_fmt->wFormat;
			    p_fmt++) {
				if ((p_fmt->wFormat == wFormat) &&
				    (p_fmt->bPrecision == bBitResolution)) {
					goto found_format;
				}
			}

			audio_if = 0;
			continue;

	found_format:

			if ((bChannels == channels) &&
			    (bBitResolution == bit_resolution)) {

				chan = (ep_dir == UE_DIR_IN) ?
				    &sc->sc_rec_chan :
				    &sc->sc_play_chan;

				if ((chan->valid == 0) && usbd_get_iface(udev, curidx)) {

					chan->valid = 1;
#ifdef USB_DEBUG
					uaudio_chan_dump_ep_desc(ed1);
					uaudio_chan_dump_ep_desc(ed2);

					if (sed->bmAttributes & UA_SED_FREQ_CONTROL) {
						DPRINTFN(2, "FREQ_CONTROL\n");
					}
					if (sed->bmAttributes & UA_SED_PITCH_CONTROL) {
						DPRINTFN(2, "PITCH_CONTROL\n");
					}
#endif
					DPRINTF("Sample rate = %dHz, channels = %d, "
					    "bits = %d, format = %s\n", rate, channels,
					    bit_resolution, p_fmt->description);

					chan->sample_rate = rate;
					chan->p_asid = asid;
					chan->p_asf1d = asf1d;
					chan->p_ed1 = ed1;
					chan->p_ed2 = ed2;
					chan->p_fmt = p_fmt;
					chan->p_sed = sed;
					chan->iface_index = curidx;
					chan->iface_alt_index = alt_index;

					if (ep_dir == UE_DIR_IN)
						chan->usb_cfg =
				      #ifdef HAS_RECORDING_SUPPORT
						    uaudio_cfg_record;
				      #else
						    NULL;
				      #endif
					else
						chan->usb_cfg =
						    uaudio_cfg_play;

					chan->sample_size = ((
					    UAUDIO_MAX_CHAN(chan->p_asf1d->bNrChannels) *
					    chan->p_asf1d->bBitResolution) / 8);

					if (ep_dir == UE_DIR_IN &&
					    usbd_get_speed(udev) == USB_SPEED_FULL) {
				      #ifdef HAS_RECORDING_SUPPORT
    						uaudio_record_fix_fs(ed1,
    						    chan->sample_size * (rate / 1000),
    						    chan->sample_size * (rate / 4000));
					    #endif
					}

					if (sc->sc_sndstat_valid) {
						//sbuf_printf(&sc->sc_sndstat, "\n\t"
						printf(&sc->sc_sndstat, "\n\t"
						    "mode %d.%d:(%s) %dch, %d/%dbit, %s, %dHz",
						    curidx, alt_index,
						    (ep_dir == UE_DIR_IN) ? "input" : "output",
						    asf1d->bNrChannels, asf1d->bBitResolution,
						    asf1d->bSubFrameSize * 8,
						    p_fmt->description, rate);
					}
				}
			}
			audio_if = 0;
			continue;
		}
	}
}

static const uint32_t uaudio_rate_list[] = {
	96000,
	88000,
	80000,
	72000,
	64000,
	56000,
	48000,
	44100,
	40000,
	32000,
	24000,
	22050,
	16000,
	11025,
	8000,
	0
};

static void
uaudio_chan_fill_info(struct uaudio_softc *sc, struct usb_device *udev)
{
	uint32_t rate = uaudio_default_rate;
	uint8_t z;
	uint8_t bits = uaudio_default_bits;
	uint8_t y;
	uint8_t channels = uaudio_default_channels;
	uint8_t x;

	bits -= (bits % 8);
	if ((bits == 0) || (bits > 32)) {
		/* set a valid value */
		bits = 32;
	}
	if (channels == 0) {
		switch (usbd_get_speed(udev)) {
		case USB_SPEED_LOW:
		case USB_SPEED_FULL:
			/*
			 * Due to high bandwidth usage and problems
			 * with HIGH-speed split transactions we
			 * disable surround setups on FULL-speed USB
			 * by default
			 */
			channels = 2;
			break;
		default:
			channels = 16;
			break;
		}
	} else if (channels > 16) {
		channels = 16;
	}
	#ifdef FIXME
	if (sbuf_new(&sc->sc_sndstat, NULL, 4096, SBUF_AUTOEXTEND)) {
		sc->sc_sndstat_valid = 1;
	}
	#endif
	/* try to search for a valid config */

	for (x = channels; x; x--) {
		for (y = bits; y; y -= 8) {

			/* try user defined rate, if any */
			if (rate != 0)
				uaudio_chan_fill_info_sub(sc, udev, rate, x, y);

			/* try find a matching rate, if any */
			for (z = 0; uaudio_rate_list[z]; z++) {
				uaudio_chan_fill_info_sub(sc, udev, uaudio_rate_list[z], x, y);

				if (sc->sc_rec_chan.valid &&
				    sc->sc_play_chan.valid) {
					goto done;
				}
			}
		}
	}

done:
	if (sc->sc_sndstat_valid) {
		sbuf_finish(&sc->sc_sndstat);
	}
}

static int
uaudio_attach(device_t dev)
{
	struct usb_attach_arg *uaa = device_get_ivars(dev);
	struct uaudio_softc *sc = device_get_softc(dev);
	struct usb_interface_descriptor *id;
	device_t child;

  DPRINTF ("%s()\n", __FUNCTION__);
  
	sc->sc_play_chan.priv_sc = sc;
	sc->sc_rec_chan.priv_sc = sc;
	sc->sc_udev = uaa->device;
	sc->sc_mixer_iface_index = uaa->info.bIfaceIndex;
	sc->sc_mixer_iface_no = uaa->info.bIfaceNum;

	device_set_usb_desc(dev);

	id = usbd_get_interface_descriptor(uaa->iface);

	uaudio_chan_fill_info(sc, uaa->device);

	//FIXME!!! uaudio_mixer_fill_info(sc, uaa->device, id);

	DPRINTF("audio rev %d.%02x\n",
	    sc->sc_audio_rev >> 8,
	    sc->sc_audio_rev & 0xff);

	DPRINTF("%d mixer controls\n",
	    sc->sc_mixer_count);

	if (sc->sc_play_chan.valid) {
		device_printf(dev, "Play: %d Hz, %d ch, %s format.\n",
		    sc->sc_play_chan.sample_rate,
		    sc->sc_play_chan.p_asf1d->bNrChannels,
		    sc->sc_play_chan.p_fmt->description);
	} else {
		device_printf(dev, "No playback.\n");
	}

	DPRINTF("doing child attach\n");

	/* attach the children */

	// FIXME!!! sc->sc_sndcard_func.func = SCF_PCM;

	/*
	 * Only attach a PCM device if we have a playback, recording
	 * or mixer device present:
	 */
	if (sc->sc_play_chan.valid ||
	    sc->sc_rec_chan.valid ||
	    sc->sc_mix_info) {
		child = device_add_child(dev, "pcm", -1);

		if (child == NULL) {
			DPRINTF("out of memory\n");
			goto detach;
		}
		// FIXME!!! device_set_ivars(child, &sc->sc_sndcard_func);
	}

	if (bus_generic_attach(dev)) {
		DPRINTF("child attach failed\n");
		goto detach;
	}
	return (0);			/* success */

detach:
	uaudio_detach(dev);
	return (ENXIO);
}

static int
uaudio_detach(device_t dev)
{
	struct uaudio_softc *sc = device_get_softc(dev);

	/*
	 * Stop USB transfers early so that any audio applications
	 * will time out and close opened /dev/dspX.Y device(s), if
	 * any.
	 */
	if (sc->sc_play_chan.valid)
		usbd_transfer_unsetup(sc->sc_play_chan.xfer, UAUDIO_NCHANBUFS);
	if (sc->sc_rec_chan.valid)
		usbd_transfer_unsetup(sc->sc_rec_chan.xfer, UAUDIO_NCHANBUFS);

	if (bus_generic_detach(dev) != 0) {
		DPRINTF("detach failed!\n");
	}
	sbuf_delete(&sc->sc_sndstat);
	sc->sc_sndstat_valid = 0;

	//umidi_detach(dev);

	return (0);
}

int
uaudio_chan_start(struct uaudio_chan *ch)
{
	ch->cur = ch->start;

#if (UAUDIO_NCHANBUFS != 2)
#error "please update code"
#endif
	if (ch->xfer[0]) {
		usbd_transfer_start(ch->xfer[0]);
	}
	if (ch->xfer[1]) {
		usbd_transfer_start(ch->xfer[1]);
	}
	return (0);
}

int
uaudio_chan_stop(struct uaudio_chan *ch)
{
#if (UAUDIO_NCHANBUFS != 2)
#error "please update code"
#endif
	usbd_transfer_stop(ch->xfer[0]);
	usbd_transfer_stop(ch->xfer[1]);
	return (0);
}

devclass_t audio_devclass;

static device_method_t audio_methods[] = {
	DEVMETHOD(device_probe, uaudio_probe),
	DEVMETHOD(device_attach, uaudio_attach),
	DEVMETHOD(device_detach, uaudio_detach),
	{0, 0}
};

static driver_t audio_driver = {
	.name = "audio",
	.methods = audio_methods,
	.size = sizeof(struct uaudio_softc),
};

DRIVER_MODULE(audio, uhub, audio_driver, audio_devclass, NULL, 0);
MODULE_DEPEND(audio, usb, 1, 1, 1);
MODULE_VERSION(audio, 1);

static struct uaudio_softc  sc;
static struct snd_dbuf      b;
static struct pcm_channel   c;
static struct uaudio_chan   *ch;

void init (void)
{
  ch = uaudio_chan_init(&sc, &b, &c, 0);
}

#endif
