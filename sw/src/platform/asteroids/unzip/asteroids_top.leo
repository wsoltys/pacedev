clean_all

set process 6
set part v300efg456
set wire_table xcve300-6_avg
set bubble_tristates FALSE

set register2register 100
set input2register 20
set register2output 20
set input2output 100

set report brief
set novendor_constraint_file TRUE
set virtex_map_iob_registers TRUE

set target xcve
load_library xcve

analyze pkg_asteroids_xilinx_prims.vhd
analyze pkg_asteroids.vhd
analyze asteroids_ram.vhd
analyze asteroids_vec_rom_1.vhd
analyze asteroids_vec_rom_2.vhd
analyze asteroids_prog_rom_0.vhd
analyze asteroids_prog_rom_1.vhd
analyze asteroids_prog_rom_2.vhd
analyze asteroids_prog_rom_3.vhd
analyze asteroids_vg.vhd
analyze asteroids_pokey.vhd
analyze asteroids.vhd
analyze t65_pack.vhd
analyze t65_mcode.vhd
analyze t65_alu.vhd
analyze t65.vhd
analyze asteroids_vtg.vhd
analyze asteroids_top.vhd
elaborate asteroids_top

pre_optimize
optimize -ta xcve -effort standard -delay -chip -hier preserve
auto_write -format EDIF asteroids_top.edf

