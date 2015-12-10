#ifndef _KL_OSD_H_
#define _KL_OSD_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <SDL_keycode.h>

#include "kl_dat.h"

#define DBGPRINTF(format...)		fprintf(stderr, format)

//#define ALLEGRO_STATICLINK

// 0=27, 1=28...
#define OSD_KEY_0     SDLK_0
#define OSD_KEY_1     SDLK_1
#define OSD_KEY_2     SDLK_2
#define OSD_KEY_3     SDLK_3
#define OSD_KEY_4     SDLK_4
#define OSD_KEY_5     SDLK_5
#define OSD_KEY_6     SDLK_6
#define OSD_KEY_7     SDLK_7
#define OSD_KEY_8     SDLK_8
#define OSD_KEY_9     SDLK_9

// A=1, B=2...
#define OSD_KEY_D     SDLK_d
#define OSD_KEY_E     SDLK_e
#define OSD_KEY_G     SDLK_g
#define OSD_KEY_I     SDLK_i
#define OSD_KEY_J     SDLK_j
#define OSD_KEY_K     SDLK_k
#define OSD_KEY_L     SDLK_l
#define OSD_KEY_N     SDLK_n
#define OSD_KEY_O     SDLK_o
#define OSD_KEY_P     SDLK_p
#define OSD_KEY_S     SDLK_s
#define OSD_KEY_U     SDLK_u
#define OSD_KEY_W     SDLK_w
#define OSD_KEY_X     SDLK_x
#define OSD_KEY_Z     SDLK_z
#define OSD_KEY_ESC   SDLK_ESCAPE

#define OSD_PRINTF(format...)		fprintf (stderr,format)

#ifdef __cplusplus
extern "C"
{
#endif
  
void osd_cls (void);
void osd_delay (unsigned ms);
int osd_key (int _key);
int osd_keypressed (void);
int osd_readkey (void);
void osd_print_text_raw (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t *str);
void osd_print_text (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, char *str);
uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t code);
void osd_print_sprite (POBJ32 p_obj);


#ifdef __cplusplus
}
#endif

#endif
