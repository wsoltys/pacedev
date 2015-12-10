#include <SDL.h>

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdint.h>
#include <sys/stat.h>
#include <memory.h>

// pandora: run msys.bat and cd to this directory
//          g++ kl.c -o kl -lallegro-4.4.2-md

// neogeo:  d:\mingw_something\setenv.bat
//          g++ kl.c -o kl -lalleg

#include "kl_osd.h"
#include "kl_dat.h"

#define ENABLE_MASK

extern void knight_lore (void);
extern uint8_t *flip_sprite (POBJ32 p_obj);

static SDL_Window *window = NULL;
static SDL_Surface *surface = NULL;
static SDL_Renderer *renderer = NULL;

static const uint8_t *key = NULL;

void osd_cls (void)
{
  SDL_SetRenderDrawColor (renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
	SDL_RenderClear (renderer);
	SDL_RenderPresent (renderer);
}

void osd_delay (unsigned ms)
{
  SDL_Delay (ms);
}

int osd_key (int _key)
{
  return (key[_key]);    
}

int osd_keypressed (void)
{
  fprintf (stderr, "%s()\n", __FUNCTION__);
  return (key[SDLK_z]);
}

int osd_readkey (void)
{
  fprintf (stderr, "%s()\n", __FUNCTION__);
  return (key[SDLK_0]);
}

void osd_print_text_raw (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t *str)
{
  unsigned c, l, b;
  
  for (c=0; ; c++, str++)
  {
    uint8_t code = *str & 0x7f;

    for (l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      
      for (b=0; b<8; b++)
      {
        if (d & (1<<7))
          SDL_RenderDrawPoint (renderer, x+c*8+b, 191-y+l);
        d <<= 1;
      }
    }  
    if (*str & (1<<7))
      break;
  }
  SDL_RenderPresent (renderer);
}

static uint8_t from_ascii (char ch)
{
  const char *chrset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.© %";
  uint8_t i;
  
  for (i=0; chrset[i]; i++)
    if (chrset[i] == ch)
      return (i);
      
    return ((uint8_t)-1);
}

void osd_print_text (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, char *str)
{
  unsigned c, l, b;
  
  for (c=0; *str; c++)
  {
    uint8_t ascii = (uint8_t)*(str++);
    uint8_t code = from_ascii (ascii);
    
    for (l=0; l<8; l++)
    {
      uint8_t d = gfxbase_8x8[code*8+l];
      if (d == (uint8_t)-1)
        break;
      
      for (b=0; b<8; b++)
      {
        if (d & (1<<7))
          SDL_RenderDrawPoint (renderer, x+c*8+b, 191-y+l);
        d <<= 1;
      }
    }  
  }
  SDL_RenderPresent (renderer);
}

uint8_t osd_print_8x8 (uint8_t *gfxbase_8x8, uint8_t x, uint8_t y, uint8_t code)
{
  unsigned l, b;
  
  for (l=0; l<8; l++)
  {
    uint8_t d = gfxbase_8x8[code*8+l];
    if (d == (uint8_t)-1)
      break;
    
    for (b=0; b<8; b++)
    {
      if (d & (1<<7))
        SDL_RenderDrawPoint (renderer, x+b, 191-y+l);
      d <<= 1;
    }
  }  
  SDL_RenderPresent (renderer);
  return (x+8);
}

void osd_print_sprite (POBJ32 p_obj)
{
  uint8_t *psprite;

  //fprintf (stderr, "(%d,%d)\n", p_obj->x, p_obj->y);

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
      for (b=0; b<8; b++)
      {
#ifdef ENABLE_MASK
        if (m & (1<<7))
        {
          SDL_SetRenderDrawColor (renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
          SDL_RenderDrawPoint (renderer, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y));
        }
          
#endif
        if (d & (1<<7))
        {
          SDL_SetRenderDrawColor (renderer, 0xFF, 0xFF, 0xFF, SDL_ALPHA_OPAQUE);
          SDL_RenderDrawPoint (renderer, p_obj->pixel_x+x*8+b, 191-(p_obj->pixel_y+y));
        }
        m <<= 1;
        d <<= 1;
      }
    }
  }
  SDL_RenderPresent (renderer);
}

int event_handler (void *unused)
{
  SDL_Event event;
  
  while (1)
  {
    if (SDL_WaitEvent (&event))
    {
      switch (event.type)
      {
        case SDL_QUIT:
          break;
      }
    }
  }
  exit (0);
}

int main (int argc, char *argv[])
{
  if (SDL_Init (SDL_INIT_VIDEO) < 0)
  {
    fprintf (stderr, "SDL_Init() failed: %s\n", SDL_GetError ());
    exit (0);
  }

  window = SDL_CreateWindow( "Knight Lore", 
                              SDL_WINDOWPOS_UNDEFINED, 
                              SDL_WINDOWPOS_UNDEFINED, 
                              256, 192, 
                              SDL_WINDOW_SHOWN ); 
  if (window == NULL) 
  { 
    fprintf (stderr, "SDL_CreateWindow() failed: %s\n", SDL_GetError()); 
    exit (0);
  }

  //surface = SDL_GetWindowSurface (window); 
  //SDL_FillRect (surface, NULL, 
  //              SDL_MapRGB (surface->format, 0xFF, 0xFF, 0xFF ));
  //SDL_UpdateWindowSurface (window);
  
  renderer = SDL_CreateRenderer (window, -1, SDL_RENDERER_ACCELERATED);
  if (renderer == NULL)
  {
    fprintf (stderr, "SDL_CreateRenderer() failed: %s\n", SDL_GetError()); 
    exit (0);
  }
      
  key = SDL_GetKeyboardState (NULL);

  SDL_Thread *event_thread = SDL_CreateThread (event_handler, "eh", NULL);

	osd_cls ();
  knight_lore ();

  SDL_DestroyWindow (window);
  SDL_Quit ();
  return (0);
  
#if 0  
  // spectrum palette
  PALETTE pal;
  for (c=0; c<16; c++)
  {
    pal[c].r = (c&(1<<1) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].g = (c&(1<<2) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
    pal[c].b = (c&(1<<0) ? ((c < 8) ? (0xCD>>2) : (0xFF>>2)) : 0x00);
  }
	set_palette_range (pal, 0, 15, 1);
#endif
}
