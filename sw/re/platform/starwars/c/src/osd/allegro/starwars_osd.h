#ifndef _ASTEROID_OSD_H_
#define _ASTEROID_OSD_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define __FORCE_RODATA__

#define DBGPRINTF(format...)		fprintf(stderr, format)

#ifdef __cplusplus
extern "C"
{
#endif

#include "allegro.h"

#define KEY_LEFT_COIN_SWITCH		KEY_5
#define KEY_MIDDLE_COIN_SWITCH	KEY_6
#define KEY_P1_START						KEY_1
#define KEY_P2_START						KEY_2
  
//void osd_delay (unsigned ms);
//void osd_clear_scrn (void);
//void osd_clear_scrn_buffer (void);
//int osd_readkey (void);
int osd_key (int _key);
//int osd_keypressed (void);
//void osd_set_palette (uint8_t attr);
//void osd_set_entire_palette (uint8_t attr);
//void osd_init_palette (void);
//uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t attr, uint8_t code);
//void osd_fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c);
//void osd_update_screen (void);
//void osd_blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines);
//void osd_print_sprite (uint8_t attr, POBJ32 p_obj);

// for debugging only
void osd_print_border (void);
void osd_display_panel (uint8_t attr);

void osd_debug_hook (void *context);
unsigned int osd_quit (void);

#ifdef __cplusplus
}
#endif

#endif
