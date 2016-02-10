
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

extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

static uint8_t osd_room_attr = 7; // white

static struct IntuitionBase *IntuitionBase;
static struct GfxBase *GfxBase;
static struct BitMap *myBitMaps[BLANK+1];
static struct Screen *screen;
static struct IOStdReq *KeyIO;
static struct MsgPort *KeyMP;
static uint8_t *keyMatrix;
  
const char __ver[40] = "$VER: Knight Lore v0.9a3 (10.02.2016)";

void osd_room_attrib (uint8_t attr)
{
  osd_room_attr = attr;
}

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
	#if 0
  return (keypressed ());
	#endif
	return (0);
}

int osd_readkey (void)
{
	#if 0
  return (readkey ());
	#endif
	return (0);
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t attr, uint8_t code)
{
  unsigned n;

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

  unsigned x, y, b;
  
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
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
    for (n=0; n<NPLANES; n++)
      p[n] -= BM_WIDTH_BYTES+w;
  }
}

void osd_debug_hook (void *context)
{
}

int main (int argc, char *argv[])
{
  unsigned i;

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
  
  // now the screen
  struct ColorSpec myColours[] = 
  { 
    {  0, 0x0000, 0x0000, 0x0000 },
#ifdef __MONO__
    {  1, 0x003F, 0x003F, 0x003F },
#else    
    {  1, 0x0000, 0x0000, 0x003F },
    {  2, 0x003F, 0x0000, 0x0000 },
    {  3, 0x003F, 0x0000, 0x003F },
    {  4, 0x0000, 0x003F, 0x0000 },
    {  5, 0x0000, 0x003F, 0x003F },
    {  6, 0x003F, 0x003F, 0x0000 },
    {  7, 0x003F, 0x003F, 0x003F },
#endif    
    { -1, 0x0000, 0x0000, 0x0000 },
  };
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
    
	knight_lore ();

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
