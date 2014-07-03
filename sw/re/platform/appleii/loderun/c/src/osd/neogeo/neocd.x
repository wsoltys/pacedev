/* $Id: neocd.x,v 1.2 2001/04/13 09:36:11 fma Exp $ */

OUTPUT_FORMAT("elf32-m68k", "elf32-m68k",
	      "elf32-m68k")
OUTPUT_ARCH(m68k)
ENTRY(_user)
 SEARCH_DIR(/usr/m68k/m68k-elf/lib);
/* Do we need any of these for elf?
   __DYNAMIC = 0;    */

MEMORY
{
  rama (rwx) : ORIGIN = 0x00000000, LENGTH = 0x10E000
  ramb (rwx) : ORIGIN = 0x00120000, LENGTH = 0xE0000
}

SECTIONS
{
  /* Read-only sections, merged into text segment: */
  . = 0x00000000 + SIZEOF_HEADERS;
  .text      :
  {
    *(.text)
    *(.text.*)
  } >rama =0x4e75
  . = ALIGN(0x10) + (. & (0x10 - 1));
  .data    :
  {
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d*)
  } >rama
  __bss_start = .;
  .bss       :
  {
   *(.bss)
   *(.bss.*)
   *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections.  */
   . = ALIGN(32 / 8);
  } >ramb
  . = ALIGN(32 / 8);
  _end = .;
  PROVIDE (end = .);
  /* Stabs debugging sections.  */
  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  .stab.excl 0 : { *(.stab.excl) }
  .stab.exclstr 0 : { *(.stab.exclstr) }
  .stab.index 0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment 0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
  /* These must appear regardless of  .  */
}


