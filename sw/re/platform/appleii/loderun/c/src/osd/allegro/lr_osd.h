#pragma once

#define OSD_KEY_I     0x09
#define OSD_KEY_J     0x0a
#define OSD_KEY_K     0x0b
#define OSD_KEY_L     0x0c
#define OSD_KEY_U     0x15
#define OSD_KEY_O     0x0f
#define OSD_KEY_ESC   0x3b

void osd_gcls (uint8_t page);
void osd_display_char_pg (uint8_t page, uint8_t chr, uint8_t x, uint8_t y);
void osd_draw_separator (uint8_t page, uint8_t byte, uint8_t y);
void osd_wipe_circle (void);
void osd_draw_circle (void);
int osd_keypressed (void);
void osd_delay (unsigned ms);
int osd_readkey (void);
int osd_key (int key);
void osd_wipe_char (uint8_t chr, uint8_t x, uint8_t y);
void osd_display_transparent_char (uint8_t chr, uint8_t x, uint8_t y);
void osd_hgr (uint8_t page);
#define OSD_HGR1  osd_hgr (0)
#define OSD_HGR2  osd_hgr (1)
void osd_flush_keybd (void);
void osd_display_title_screen (uint8_t page);
