#ifndef _LR_OSD_H_
#define _LR_OSD_H_

#define HAS_HWSPRITES

#define LR_KEY_A     		('A' & 0x3f)
#define LR_KEY_I     		('I' & 0x3f)
#define LR_KEY_J     		('J' & 0x3f)
#define LR_KEY_K     		('K' & 0x3f)
#define LR_KEY_L     		('L' & 0x3f)
#define LR_KEY_U     		('U' & 0x3f)
#define LR_KEY_O     		('O' & 0x3f)
#define LR_KEY_X     		('X' & 0x3f)
#define LR_KEY_Z     		('Z' & 0x3f)
#define LR_KEY_ESC   		0x3b
#define LR_KEY_BS				0x08
#define LR_KEY_CR				0x0d
#define LR_KEY_RIGHT		0x95
#define LR_KEY_SPACE		0xA0
#define LR_KEY_PERIOD		0xAE

#include <string.h>
#include <video.h>

#define OSD_PRINTF(format...)
//#define OSD_PRINTF(format...) textoutf (0, 27, 0, 0, format)

typedef struct hs_entry_t
{
	uint8_t		initial[3];
	uint8_t		level;
	uint32_t	score;
	
} HS_ENTRY, *PHS_ENTRY;

void osd_gcls (uint8_t page);
void osd_display_char_pg (uint8_t page, uint8_t chr, uint8_t x, uint8_t y);
void osd_draw_separator (uint8_t page, uint8_t byte, uint8_t y);
void osd_wipe_circle (void);
void osd_draw_circle (void);
int osd_keypressed (void);
void osd_delay (unsigned ms);
int osd_readkey (void);
int osd_key (int key);
void osd_wipe_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y);
void osd_display_transparent_char (int8_t sprite, uint8_t chr, uint8_t x_div_2, uint8_t y);
void osd_hgr (uint8_t page);
#define OSD_HGR1  osd_hgr (1)
#define OSD_HGR2  osd_hgr (2)
void osd_flush_keybd (void);
void osd_display_title_screen (uint8_t page);
void osd_game_over_frame (uint8_t frame, const uint8_t game_over_frame[][14], const uint8_t gol[][26]);
void osd_load_high_scores (PHS_ENTRY hs_tbl);
void osd_save_high_scores (PHS_ENTRY hs_tbl);

#endif
