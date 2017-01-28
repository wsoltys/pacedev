Retro Ports: Lode Runner - Release Notes
========================================
Mark McDougall, 2014
msmcdoug@gmail.com

Lode Runner is one of my all-time favourite games on any platform.

The game should need no introdution, and it is testament to the game that it has received countless ports, clones and sequels on dozens of platforms over the years, from 8-bit micros to modern-day consoles and their on-line services. Even the Coco had a port back in 1984 - Tom Mix Software's Gold Runner and its sequel Gold Runner II (it's debatable whether the later Gold Runner 2000 is a true clone). But for me personally, although most incarnations are fun to play, only a select few are faithful ports and there's simply no substitute for the 1983 Apple II original by Doug Smith.

This project is the culmination of an attempt that actually started in the 80's to produce a 100% faithful port on the TRS-80. My initial intention was to port it to the TRS-80 Model 4 with Micro Labs Grafyx Solution hires board - and I have actually started that port - but due to technical reasons I've opted to focus for now on the 6809-based Color Computer 3. As part of the porting process, I've also reverse-engineered (documented) every single line of [ported] code, both for the 6502 original and the 6809 port (~5,800 lines) - something I've been wanting to do for 25+ years! I should note at this point that I have absolutely no intention of porting the level editor.

The port itself is - essentially - a line-by-line hand translation of the 6502 assembler to 6809 assembler. For people that are familar with both processors, it's perhaps not surprising to learn that for the bulk of the code I was able to effect a 1:1 mapping of the instructions from 6502 to 6809. There was some shuffling of the 6502 X,Y registers into the 6809 B register, but for the most part the former weren't used at the same time. The 6502 zero-page area was emulated with the 6809 DP register, although the indexed indirect mode of access on the 6502 zero-page had to be emulated using the Y and B registers on the 6809. Fortunately there is sufficient head-room on the Coco to handle this extra complexity.

Where the port was dramatically changed was the hardware (graphics, keyboard) accesses. The horribly broken nature of the Apple II's video mapping meant that the low-level graphics routines were replaced with simpler graphics data formats and corresponding rendering routines with little in common with the orignal routines. Anything even remotely resembling the Apple II's keyboard controller is also noticably absent on the Coco, so low-level changes had to be implemented there as well. Sound however was trivial - bit-bashing 1-bit sound is the same on any platform.

Otherwise, I've purposefully made no attempt to optimise or otherwise improve the 6502 code for the 6809. This is, in part, because I reasoned that the port would be easier to debug if the code was a direct translation (and I maintain that it was actually the case). It was also because I wanted to preserve the 'style' and implementation of the actual code itself, as well as the game-play, as a tribute to the original. Here, I think I've also succeeded.

The end result is what I claim to be a 100% accurate, pixel-perfect port of the Apple II original to the Coco 3. The graphics and animation are perfect, the AI is perfect, the game-play is 100% accurate. Playing on the Coco is an authentic Apple II Lode Runner experience. Except for the improvements. ;)

Improvements? The Apple II is incapable of detecting when a key is released. Hence the player on the Apple II version continues in the same direction until another key is pressed. To my knowledge, no other port on any system mirrors this behaviour, and I would claim that it is borne of necessity rather than design. Collaborating my claim is the fact that the joystick controls do not emulate this same behaviour. To this end, I've implemented the keyboard input as I believe it should have been - or rather - that is my intention. At the moment the code works as the original; I'll need to tweak it a little to get optimal behaviour from the Coco keyboard. But for now, it's still an improvement over the original.

So without further ado, I present you Apple II Lode Runner for the TRS-80 Color Computer 3!

System Requirements
-------------------
TRS-80 Color Computer 3
128KB RAM (or more)
Floppy Disk or equivalent (Drive Wire, etc) -or-
Lode Runner Game cartridge

Keys
----
<I>,<UP>      UP
<K>,<DOWN>    DOWN
<J>,<LEFT>    LEFT
<L>,<RIGHT>   RIGHT
<U>,<Z>       DIG LEFT
<O>,<X>       DIG RIGHT
<CTRL><N>     Next level (cheat)
<CTRL><F>     Extra life (cheat)
<ESC>         Freeze
<CTRL><R>     Abort game
<CTRL><A>     Abort life
<CTRL><J>     Enable joystick (disable keyboard)
<CTRL><K>     Enable keyboard (disable joystick)
<CTRL><S>     Toggle sound
<CTRL><H>     Speed up game (not tested)
<CTRL><U>     Slow down game (not tested)
<ENTER>       Display High Scores

Note that using the keys marked as 'cheat' will disqualify you from the high score list.

Special Keys on the title screen ONLY
-------------------------------------
<F2>          Toggle Green/Amber/White for monochrome

Yet To Be Implemented (in roughly planned order)
---------------------
* High Score load/save
* Inclusion of all 150 levels
* Support for Championship Lode Runner (+50 levels)

Comments/Suggestions/Bugs
-------------------------
* Please send any to the email address at the top of these notes.

Release History
---------------
v0.4        Playable Demo Release (Beta 4)
            Fixed 32CPL splash screen on floppy version
            Added joystick support
            Detect PAL/NTSC for palette prompt
            Playable levels now back to 8 because of code space issues
            
v0.3        Playable Demo Release (Beta 3)
            Fixed GAME OVER animation for MONOCHROME mode
            Removed RGB/Composite toggle in-game
            Added Amber mode for monochrome builds
            1BPP, Mono 2BPP & Colour 2BPP separate builds

v0.2        Playable Demo Release (Beta 2)
            Added Game Over animation
            Added Freeze function
            Fixed Extra Life key detection
            Added support for ARROW,Z,X keys
            Added colour mode
            (Better) centred screen
            Support for 128KB machines (untested)
            *Added another 5 levels (now 10 levels) ???
            Fixed stack bug, possible cause of crash
            Added circular wipe function
            Added sound
            Added palette change keys

v0.1        Playable Demo Release (Beta 1)
            Monochrome, 5 levels only
