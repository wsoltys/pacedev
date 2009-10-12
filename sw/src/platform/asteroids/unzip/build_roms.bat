@echo off
set rom_path_src=roms\rev1\
set rom_path=roms\

 romgen %rom_path_src%036430.02 ASTEROIDS_PROG_ROM_0 11 b r > %rom_path%ASTEROIDS_PROG_ROM_0.vhd
 romgen %rom_path_src%036431.02 ASTEROIDS_PROG_ROM_1 11 b r > %rom_path%ASTEROIDS_PROG_ROM_1.vhd
 romgen %rom_path_src%036432.02 ASTEROIDS_PROG_ROM_2 11 b r > %rom_path%ASTEROIDS_PROG_ROM_2.vhd
 romgen %rom_path_src%036433.03 ASTEROIDS_PROG_ROM_3 11 b r > %rom_path%ASTEROIDS_PROG_ROM_3.vhd

 romgen %rom_path_src%036800.02 ASTEROIDS_VEC_ROM_1  11 b r > %rom_path%ASTEROIDS_VEC_ROM_1.vhd
 romgen %rom_path_src%036799.01 ASTEROIDS_VEC_ROM_2  11 b r > %rom_path%ASTEROIDS_VEC_ROM_2.vhd

echo done

