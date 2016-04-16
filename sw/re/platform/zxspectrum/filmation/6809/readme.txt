ZX Spectrum Knight Lore for the TRS-80 Color Computer 3
=======================================================

       <http://www.retroports.blogspot.com.au>
             <mailto:msmcdoug@gmail.com>

Introduction
------------
                                                                                
Released in 1984 by Ultimate Play the game, Knight Lore was a seminal title for 
the ZX Spectrum and would popularise isometric graphics in computer games in the
years that followed. A smash hit upon release, it was followed up with two      
spiritual sequels, Alien 8 and Pentagram, with only minor updates to the        
filmation engine at the core of the game.                                       
                                                                                
This project began with a complete reverse-engineering of the original Z80 code.
I then re-coded the game in C, to facilitate porting of the game to more capable
platforms such as the Amiga and the Neo Geo. Finally, I translated the original 
Z80 listing to 6809 in order to replicate the exact behaviour - every nuance and
even (almost) every bug - of the ZX Spectrum game. The graphics data has    
been lifted directly from the Z80 code; it's a pixel-perfect port, they simply  
don't get any more faithful than this.                                          
                                                                                
Due to the nature of the hardware, this port is a little less colourful than the
Z80 spectrum original (in the panel display only), but this has no affect at all 
on the game play. In fact, the official BBC Micro port also had a completely 
monochrome display.


Instructions
------------

Please refer to the original ZX Spectrum documentation for the back story, rules
and object of the game. The only difference in the Coco version is the mapping
of the inputs.

Currently the inputs are restricted to a single key per function, unlike the
original which maps the entire keyboard.

Rotational Controls: (Keyboard, Joystick)
LEFT            <Z>           <LEFT>
RIGHT           <X>           <RIGHT>
FORWARD         <A>           <UP>
JUMP            <Q>           <Z>
PICK-UP/DROP    <1>           <DOWN>

Directional Controls (Joystick only):
NORTH           <UP>
SOUTH           <DOWN>
EAST            <RIGHT>
WEST            <LEFT>
JUMP            <BUTTON 1>
PICK-UP/DROP    <BUTTON 2>

Miscellaneous Controls:
PAUSE GAME      <SPACE>


Bugs/glitches/notes
-------------------

Panel border pixels glitch: under certain circumstances, a few pixels on the 
border of the panel are wiped by the player's sprite when exiting to the south
of the room. This is an artifact of the original game and hence shall remain
part of the Knight Lore "exprience" on the Coco3.

Slowdown: the original ZX Spectrum game experiences significant slowdown when
larger numbers of sprites have to be wiped and re-rendered, typically in
"busy" rooms and especially rooms with moving objects.


Release notes
-------------

CocoFEST Demo Version 1.1

Added a build option for Mick Farrow graphics. Back in 2002, Mick Farrow 
modified the original sprites to add more shading (via dithering) and also
sharpen the outline of some sprites.

Updated the Main Menu specifically for the Coco3 port. Added the ability to
select keyboard/joystick and directional controls.

Added support for directional & rotational joystick input.

Added 4 missing sounds; pickup/drop, extra life, pause & unpause.


CocoFEST Demo Version 1.0

The game is complete but speed control is preliminary and there has been no
optimisation in any areas of the code. The very noticable slow-downs that occur
throughout the game are endemic to the original game running on the ZX Spectrum.
I would argue that it does not appear to the casual observer to be significantly 
slower on the Coco and although I have not yet done any sort of scientfic 
analysis on the performance it's entirely possible that the Coco port is (at 
this point) at its slowest, slower than the ZX Spectrum. Regardless, I expect 
to be able to improve speed with some code optimisations before the final
release.

Ignore the contents of the main menu, it has been ported verbatim from the ZX
Spectrum. Once joystick support has been added (see below) the menu will be
modified specifically for the Coco3 port. Currently only START GAME has been
implemented.

Sun/moon frame graphics glitch: under certain circumstances, remnants of the
sum/moon either side of the frame in the right-hand side of the panel are
visible. This is an artifact of the original code, however on the ZX Spectrum
these areas were given a black-on-black attribute in order to conceal them.
The Amstrad CPC, OTOH, extended the width of the frame sprite to cover the
remnants. I intend to rectify this on the Coco3 port before final release.

Joystick (and hence direction control) support has not been implemented. I plan
to add that before the final release. The keyboard controls may be modified
and/or enhanced also.

The Amstrad CPC version enhanced the graphics with 2BPP and "two-tone" display
of the rendered rooms. Whilst the size of the graphics data is the same as the
monochrome ZX Spectrum graphics, there's double the amount of video memory to
manipulate. I am hoping, however, that with sufficient code optimisations I
will be able to implement the CPC graphics on the Coco3 with acceptable
performance.
