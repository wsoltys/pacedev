--
-- A simulation model of Asteroids hardware
-- Copyright (c) MikeJ - May 2005
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email support@fpgaarcade.com
--

 Revision list

 version 003 cpu update
 version 002 pokey fix in self test
 version 001 initial release


 The design is a bit Xilinx specific at the moment, this will be fixed shortly.

 The following scripts will create a directory called 'build', copy the source
 files, run the sythesizer and Xilinx place and route tools.

 Assuming the Xilinx tools are installed and working, expand the distribution
 zip file (maintaining directory structure).

 Fire up a command prompt and navigate to the directory.

 run :

 Build_roms.bat - this will convert the files in the Roms directory to VHDL
		  files (also in the Roms directory). These may then be used
		  if you wish to simulate the design. Note, the rom binaries
		  provided are blank.

 then either :

 Build_leo.bat - Xilinx build script using Leonardo
		 (uses asteroids_leo.ucf constraints file)

 or

 Build_xst.bat - Xilinx build script using Xilinx WebPak
		 (uses asteroids_xst.ucf constraints file)

 if you add a /xil switch, the script will not run the synthesizer, just the
 place and route tools. You will be left with a .bit file in the Build directory
 you can use to program a chip. Remember to modify the .ucf file for your
 pinout.

 As it is wired up at the moment a 40Mhz clock is required.

 Additional Notes :

   Button shorts input to ground when pressed
   external pull ups of 1k are recommended.

 Audio out :

   Use the following resistors for audio out DAC :
   audio_out(7) 510   (MSB)
   audio_out(6) 1K
   audio_out(5) 2K2
   audio_out(4) 4K7
   audio_out(3) 10K
   audio_out(2) 22K
   audio_out(1) 47K
   audio_out(0) 100K  (LSB) -- common to amplifier

    Although, to be honest, if you only use 7 downto 4 you will be hard pushed
    to know the difference.

 Video Out :

   Video out DAC's. Values here give 0.7 Volt peek video output
   reduce resistor values for old arcade monitors

   Use the following resistors for Video DACs :

   video_out(3) 510
   video_out(2) 1k
   video_out(1) 2k2
   video_out(0) 4k7


 Cheers,

 MikeJ
