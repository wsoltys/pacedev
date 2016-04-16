
// osd stuff

#include <exec/memory.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <devices/keyboard.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <hardware/blit.h>
#include <stdlib.h>

#include "osd_types.h"
#include "kl_osd.h"

//#define __MONO__
#ifdef __MONO__
  #define NPLANES   1
#else
  #define __COLOUR__
  #define NPLANES   3
#endif

#define ENABLE_MASK

// bitmaps
#define VIDBUF          0
#define VIDEO           1
#define BLANK           2
#define BM_WIDTH        256
#define BM_HEIGHT       200
#define BM_WIDTH_BYTES  (BM_WIDTH/8)
#define PL_SIZE         (BM_WIDTH_BYTES*BM_HEIGHT)

extern void knight_lore (GFX_E gfx_);
extern uint8_t *flip_sprite (POBJ32 p_obj);

static struct IntuitionBase *IntuitionBase;
static struct GfxBase *GfxBase;
static struct BitMap *myBitMaps[BLANK+1];
static struct Screen *screen;
static struct IOStdReq *KeyIO;
static struct MsgPort *KeyMP;
static uint8_t *keyMatrix;
static struct ColorSpec myColours[8+1];
  
static void make_zx_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b);
static void make_cpc_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b);
static void make_amiga_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b, struct ColorSpec *cs);

const char __ver[] = "\0$VER: KnightLore 09.6 (15.04.2016)"
#ifdef __MONO__
" (mono)"
#endif
;

void osd_delay (unsigned ms)
{
  Delay (ms/20);
}

void osd_clear_scrn (void)
{
  unsigned n;
  
  //SetRast (&(screen->RastPort), ON_PEN);
  for (n=0; n<NPLANES; n++)
    BltClear (myBitMaps[VIDEO]->Planes[n], PL_SIZE, 1);
}

void osd_clear_scrn_buffer (void)
{
  unsigned n;
  
  for (n=0; n<NPLANES; n++)
    BltClear (myBitMaps[VIDBUF]->Planes[n], PL_SIZE, 1);
}

int osd_key (int _key)
{
  KeyIO->io_Command = KBD_READMATRIX;
  KeyIO->io_Data = (APTR)keyMatrix;
  //KeyIO->io_Length= SysBase->lib_Version >= 36 ? MATRIX_SIZE : 13;
  KeyIO->io_Length = 13;
  DoIO ((struct IORequest *)KeyIO);

  if (keyMatrix[_key>>3] & (1<<(_key&7)))
    return (1);
      
	return (0);
}

int osd_keypressed (void)
{
  unsigned i;
  
  KeyIO->io_Command = KBD_READMATRIX;
  KeyIO->io_Data = (APTR)keyMatrix;
  //KeyIO->io_Length= SysBase->lib_Version >= 36 ? MATRIX_SIZE : 13;
  KeyIO->io_Length = 13;
  DoIO ((struct IORequest *)KeyIO);

  for (i=0; i<13; i++)
    if (keyMatrix[i])
      return (1);
      
	return (0);
}

int osd_readkey (void)
{
	#if 0
  return (readkey ());
	#endif
	return (0);
}

void osd_init_palette (void)
{
  unsigned c;
  
  // palette - ZX colours which don't change
  for (c=0; c<8; c++)
  {
    uint8_t r, g, b;

    #ifdef __MONO__
      make_zx_colour (c==1 ? 15 : 0, &r, &g, &b);
    #else    
      make_zx_colour (8+c, &r, &g, &b);
    #endif
    make_amiga_colour (c, &r, &g, &b, &myColours[c]);
  }
  myColours[c].ColorIndex = -1;
}

void osd_set_palette (uint8_t attr)
{
  unsigned c;
  
  static const uint8_t room_pal[][4] =
  {    
    // orange, yellow, white
    { 0, 15, 24, 26 },
    // green, cyan, magenta
    { 0, 18, 20, 8 },
    // blue, cyan, yellow
    { 0, 2, 20, 24 },
    // red, yellow, white
    { 0, 6, 24, 26 }
  };

  // nothing to do for ZX version
  if (IS_ZX(gfx))
    return;
    
  if (attr == 0)
  {
    // default ZX palette
    for (c=0; c<8; c++)
    {
      uint8_t r, g, b;
  
      make_zx_colour (8+c, &r, &g, &b);
      SetRGB4 (&(screen->ViewPort), c, r>>4, g>>4, b>>4);
    }
  }
  else
  {    
    attr &= 3;
    for (c=0; c<4; c++)
    {
      uint8_t r, g, b;
      make_cpc_colour (room_pal[attr][c], &r, &g, &b);
      SetRGB4 (&(screen->ViewPort), c, r>>4, g>>4, b>>4);
    }
  }
}

void osd_set_entire_palette (uint8_t attr)
{
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t attr, uint8_t code)
{
  unsigned n;

  if (gfx == GFX_CPC && IS_ROOM_ATTR(attr))
    attr = 3;
    
  for (n=0; n<NPLANES; n++)
  {
    uint8_t *p = (uint8_t *)myBitMaps[VIDBUF]->Planes[n];
    p += (191-y)*BM_WIDTH_BYTES+x/8;

    unsigned l;
    for (l=0; l<8; l++)
    {
      uint8_t d;

      #ifdef __COLOUR__
        if ((attr & (1<<n)) == 0)
          *p = 0;
        else
      #endif
          *p = gfxbase_8x8[code*8+l];
        
      p += BM_WIDTH_BYTES;    
    }  
  }
  return (x+8);
}

void osd_fill_window (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines, uint8_t c)
{
#if 1
  uint8_t *p;
  unsigned o = (191-((unsigned)y+(unsigned)height_lines-1))*BM_WIDTH_BYTES + (unsigned)x/8;
  unsigned h = height_lines;
  unsigned n;
  
  for (n=0; n<NPLANES; n++)
  {
    p = (uint8_t *)(myBitMaps[VIDBUF]->Planes[n]) + o;
    for (h=0; h<height_lines; h++)
    {
      memset (p, c, width_bytes);
      p += BM_WIDTH_BYTES;
    }
  }
#else  
  // for some reason this doesn't work for the sun/moon
  // - passes in (184, 0, 6, 31, 0)
  BltBitMap (myBitMaps[BLANK], x, 191-(y+height_lines-1),
              myBitMaps[VIDBUF], x, 191-(y+height_lines-1),
              width_bytes<<3, height_lines, 
              0xc0, 0xff, 0);
#endif
}

void osd_update_screen (void)
{
  BltBitMapRastPort (myBitMaps[VIDBUF], 0, 0, 
                      &(screen->RastPort), 0, 0, 
                      BM_WIDTH, BM_HEIGHT, 0xC0);
}

void osd_blit_to_screen (uint8_t x, uint8_t y, uint8_t width_bytes, uint8_t height_lines)
{
  BltBitMapRastPort (myBitMaps[VIDBUF], x, 191-(y+height_lines-1), 
                      &(screen->RastPort), x, 191-(y+height_lines-1), 
                      width_bytes<<3, height_lines, 
                      0xC0);
}

void osd_print_sprite (uint8_t attr, POBJ32 p_obj)
{
  uint8_t *psprite;

  uint8_t *p[NPLANES];
  uint8_t o = p_obj->pixel_x & 7;

  unsigned n;
  for (n=0; n<NPLANES; n++)
  {
    p[n] = (uint8_t *)myBitMaps[VIDBUF]->Planes[n];
    p[n] += (191-p_obj->pixel_y)*BM_WIDTH_BYTES + p_obj->pixel_x/8;
  }
  
  //DBGPRINTF("(%d,%d)\n", p_obj->x, p_obj->y);

  // references p_obj
  psprite = flip_sprite (p_obj);

  uint8_t w = *(psprite++) & 0x3f;
  uint8_t h = *(psprite++);
  uint8_t f;
  
  if (gfx == GFX_CPC)
  {
    w /= 2;
    f = *(psprite++);
  }

  unsigned x, y, b;

  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      if (IS_ZX(gfx))
      {  
        uint8_t m = *(psprite++);
        uint8_t d = *(psprite++);
  
        for (n=0; n<NPLANES; n++)
        {      
          // handle bit-shift
          uint8_t v = *p[n];
          #ifdef ENABLE_MASK
            v &= ~(m>>o);
          #endif
          #ifdef __COLOUR__
            if ((attr & (1<<n)) != 0)
          #endif
              v |= (d>>o);
          *(p[n]++) = v;
          if (o != 0)
          {
            v = *p[n];
            #ifdef ENABLE_MASK
              v &= ~(m<<(8-o));
            #endif
            #ifdef __COLOUR__
              if ((attr & (1<<n)) != 0)
            #endif
                v |= (d<<(8-o));
            *p[n] = v;
          }
        }
      }
      else
      if (gfx == GFX_CPC)
      {
        uint8_t d[2], t, m, c1, c3, v;

        d[0] = *(psprite++);
        t = *(psprite++);
        d[1] = (d[0]&0xf0) | (t>>4);
        d[0] = (d[0]<<4) | (t&0x0f);
        m = d[1]|d[0];
        c1 = d[0]&~d[1];
        c3 = d[1]&d[0];
        if (f == 0)
        {
          d[1] &= ~(c3);
          d[0] &= ~(c3);
        }
        else
          d[1] |= c1;
        for (n=0; n<2; n++)
        {
          v = *p[n];
          v &= ~(m>>o);
          v |= (d[n]>>o);
          *(p[n]++) = v;
          if (o != 0)
          {
            v = *p[n];
            v &= ~(m<<(8-o));
            v |= (d[n]<<(8-o));
            *p[n] = v;
          }
        }
      }
    }
    for (n=0; n<NPLANES; n++)
      p[n] -= BM_WIDTH_BYTES+w;
  }
}

void osd_debug_hook (void *context)
{
}

void make_zx_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  *r = (c&(1<<1) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
  *g = (c&(1<<2) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
  *b = (c&(1<<0) ? ((c < 8) ? 0xCD : 0xFF) : 0x00);
}

void make_cpc_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b)
{
  uint8_t lu[] = { 0, 128, 255 };
  
  *r = lu[(c/3) % 3];
  *g = lu[(c/9) % 3];
  *b = lu[c % 3];
}

void make_amiga_colour (uint8_t c, uint8_t *r, uint8_t *g, uint8_t *b, struct ColorSpec *cs)
{
  cs->ColorIndex = c;
  cs->Red = *r >> 2;
  cs->Green = *g >> 2;
  cs->Blue = *b >> 2;
}

void usage (char *argv0)
{
  printf ("usage: kl {-cpc|-zx}\n");
#ifndef __MONO__  
  printf ("  -cpc    use Amstrad CPC graphics\n");
#endif  
  printf ("  -mf     use Mick Farrow's modfied ZX Spectrum graphics\n");
  printf ("  -zx     use ZX Spectrum graphics\n");
  printf ("  -v      print version information\n");
  exit (0);
}

int main (int argc, char *argv[])
{
  GFX_E gfx = GFX_ZX;
  unsigned c, i;

  while (--argc)
  {
    switch (argv[argc][0])
    {
      case '-' :
      case '/' :
      #ifndef __MONO__
        if (!stricmp (&argv[argc][1], "cpc"))
          gfx = GFX_CPC;
        else
      #endif
        if (!stricmp (&argv[argc][1], "mf"))
          gfx = GFX_ZX_MICK_FARROW;
        else
        if (!stricmp (&argv[argc][1], "zx"))
          gfx = GFX_ZX;
        else
        switch (tolower(argv[argc][1]))
        {
          case 'v' :
            printf ("%s\n", __ver+1);
            exit (0);
            break;
          default :
            usage (argv[0]);
            break;
        }
        break;
      default :
        usage (argv[0]);
        break;
    }
  }

  // the usual AmigaOS stuff  
  IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 40);
  GfxBase = (struct GfxBase *)OpenLibrary ("graphics.library", 40);

  // setup keyboard
  KeyMP = (struct MsgPort *)CreatePort (NULL, NULL);
  KeyIO = (struct IOStdReq *)CreateExtIO (KeyMP, sizeof(struct IOStdReq));
  OpenDevice ("keyboard.device", NULL, (struct IORequest *)KeyIO, NULL);
  keyMatrix = AllocMem (16, MEMF_PUBLIC|MEMF_CLEAR);

  // now the video memory
  myBitMaps[VIDBUF] = (struct BitMap *)AllocMem ((LONG)sizeof(struct BitMap), MEMF_CLEAR);
  myBitMaps[VIDEO] = (struct BitMap *)AllocMem ((LONG)sizeof(struct BitMap), MEMF_CLEAR);
  myBitMaps[BLANK] = (struct BitMap *)AllocMem ((LONG)sizeof(struct BitMap), MEMF_CLEAR);
  
  InitBitMap (myBitMaps[VIDBUF], NPLANES, BM_WIDTH, BM_HEIGHT);
  InitBitMap (myBitMaps[VIDEO], NPLANES, BM_WIDTH, BM_HEIGHT);
  InitBitMap (myBitMaps[BLANK], NPLANES, BM_WIDTH, BM_HEIGHT);

  for (i=0; i<NPLANES; i++)
  {
    myBitMaps[VIDBUF]->Planes[i] = (PLANEPTR)AllocRaster (BM_WIDTH, BM_HEIGHT);
    BltClear (myBitMaps[VIDBUF]->Planes[i], PL_SIZE, 1);
    myBitMaps[VIDEO]->Planes[i] = (PLANEPTR)AllocRaster (BM_WIDTH, BM_HEIGHT);
    BltClear (myBitMaps[VIDEO]->Planes[i], PL_SIZE, 1);
    // for fill_window
    myBitMaps[BLANK]->Planes[i] = (PLANEPTR)AllocRaster (BM_WIDTH, BM_HEIGHT);
    BltClear (myBitMaps[BLANK]->Planes[i], PL_SIZE, 1);
  }
  
  osd_init_palette ();
  
  // now the screen  
  screen = OpenScreenTags (NULL, 
              SA_Left, 0,
              SA_Top, 0,
              SA_Width, BM_WIDTH,
              SA_Height, BM_HEIGHT,
              SA_Depth, NPLANES,
              SA_Type, CUSTOMSCREEN|CUSTOMBITMAP|SCREENQUIET,
              SA_BitMap, (ULONG)myBitMaps[VIDEO],
              SA_Colors, (ULONG)myColours,
              TAG_DONE);
  
  // link in the bitmap
  screen->RastPort.BitMap = myBitMaps[VIDEO];
  screen->ViewPort.RasInfo->BitMap = myBitMaps[VIDEO];

  //MakeScreen (screen);
  //RethinkDisplay ();
    
	knight_lore (gfx);

  CloseScreen (screen);
  
  for (i=0; i<NPLANES; i++)
  {
    FreeRaster (myBitMaps[VIDBUF]->Planes[i], BM_WIDTH, BM_HEIGHT);
    FreeRaster (myBitMaps[VIDEO]->Planes[i], BM_WIDTH, BM_HEIGHT);
    FreeRaster (myBitMaps[BLANK]->Planes[i], BM_WIDTH, BM_HEIGHT);
  }
  FreeMem (myBitMaps[VIDBUF], (ULONG)sizeof(struct BitMap));
  FreeMem (myBitMaps[VIDEO], (ULONG)sizeof(struct BitMap));
  FreeMem (myBitMaps[BLANK], (ULONG)sizeof(struct BitMap));

  FreeMem (keyMatrix, 16);
  CloseDevice ((struct IORequest *)KeyIO);
  DeleteExtIO ((struct IORequest *)KeyIO);
  DeletePort (KeyMP);
  
  if (GfxBase)
    CloseLibrary ((struct Library *)GfxBase);
  if (IntuitionBase) 
    CloseLibrary ((struct Library *)IntuitionBase);
    
  return (0);
}
