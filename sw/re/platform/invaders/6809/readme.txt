Arcade Space Invaders for the TRS-80 Color Computer 3
=====================================================

     <http://www.retroports.blogspot.com.au>
           <mailto:msmcdoug@gmail.com>

Introduction
------------
                                                                                
Space Invaders needs no introduction.

This port is a line-by-line translation from the original 8080 code to 6809. 
The original graphics data is used, albeit rotated for the horizontal screen 
of the Coco3, but otherwise unmodified. The result is a pixel-perfect port 
that plays exactly like the original arcade game.

Many years ago I reverse-engineered the arcade code. However I've decided to
base this port on the dissassambly found on Computer Archeology, since it is
arguably more complete than mine. Every comment from that listing is replicated
on the corresponding 6809 listing.

This port is currently in Alpha stage. The screen is yet to be rotated, sound is
yet to be added, and the game is still monochrome. However running this in MESS
with a rotated screen will give you an idea of what you can expect when the port
is complete.


Instructions
------------

Defend Earth from the Invaders from Space. Duh!

Keyboard Controls:
COIN UP         <5>
P1 START        <1>
P2 START        <2>
LEFT            <LEFT>
RIGHT           <RIGHT>
FIRE            <SPACE>
TILT            <CTRL><BREAK>

Bugs/glitches/notes
-------------------

Screen has not been rotated for the Coco3.

No Sound.

Monochrome only.

No joystick input.


Release notes
-------------

Alpha Version 0.9

The port is complete and 100% accurate. Aside from screen rotation, the game
lacks colour and sound, both of which I hope to rectify.

For best results use:

MESS coco3 -cart si.rim -rol

or

MESS coco3 -flop1 si_6809.dsk -rol
run "si

