#ifndef _KL_OSD_H_
#define _KL_OSD_H_

#include <string.h>
#include <video.h>

#include "kl_dat.h"

#define __HAS_HWSPRITES__

// 0=27, 1=28...
#define OSD_KEY_0       0x0A
#define OSD_KEY_1       0x01
#define OSD_KEY_2       0x02
#define OSD_KEY_3       0x03
#define OSD_KEY_4       0x04
#define OSD_KEY_5       0x05
#define OSD_KEY_6       0x06
#define OSD_KEY_7       0x07
#define OSD_KEY_8       0x08
#define OSD_KEY_9       0x09
                        
// A=1, B=2...          
#define OSD_KEY_A       0x20
#define OSD_KEY_B       0x35
#define OSD_KEY_C       0x33
#define OSD_KEY_D       0x22
#define OSD_KEY_E       0x12
#define OSD_KEY_F       0x23
#define OSD_KEY_G       0x24
#define OSD_KEY_H       0x25
#define OSD_KEY_I       0x17
#define OSD_KEY_J       0x26
#define OSD_KEY_K       0x27
#define OSD_KEY_L       0x28
#define OSD_KEY_M       0x37
#define OSD_KEY_N       0x36
#define OSD_KEY_O       0x18
#define OSD_KEY_P       0x19
#define OSD_KEY_Q       0x10
#define OSD_KEY_R       0x13
#define OSD_KEY_S       0x21
#define OSD_KEY_T       0x14
#define OSD_KEY_U       0x16
#define OSD_KEY_V       0x34
#define OSD_KEY_W       0x11
#define OSD_KEY_X       0x32
#define OSD_KEY_Y       0x15
#define OSD_KEY_Z       0x31
#define OSD_KEY_SPACE   0x40
#define OSD_KEY_ESC     0x45

#define DBGPRINTF(format...)
//#define OSD_PRINTF(format...)
//#define OSD_PRINTF(format...) textoutf (0, 27, 0, 0, format)

#define abs(v)        ((v)<0?-(v):(v))

void osd_delay (unsigned ms);
void osd_clear_scrn (void);
void osd_clear_scrn_buffer (void);
int osd_key (int _key);
int osd_keypressed (void);
int osd_readkey (void);
void osd_print_text_raw (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t *str);
void osd_print_text (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, char *str);
uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t code);
void osd_fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c);
void osd_update_screen (void);
void osd_blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines);
void osd_print_sprite (POBJ32 p_obj);

#endif // __KL_OSD_H__
