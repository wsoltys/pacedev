/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu_0' in SOPC Builder design 'ep4c_sopc_system'
 * SOPC Builder design path: ../../ep4c_sopc_system.sopcinfo
 *
 * Generated: Wed Nov 23 22:46:24 EST 2011
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x21000020
#define ALT_CPU_CPU_FREQ 72500000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x0
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1f
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x40000100
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 72500000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_EXTRA_EXCEPTION_INFO
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_ILLEGAL_MEMORY_ACCESS_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 8192
#define ALT_CPU_INST_ADDR_WIDTH 0x1f
#define ALT_CPU_NAME "cpu_0"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_RESET_ADDR 0x20000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x21000020
#define NIOS2_CPU_FREQ 72500000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x0
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x1f
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x40000100
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_EXTRA_EXCEPTION_INFO
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_ILLEGAL_MEMORY_ACCESS_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 8192
#define NIOS2_INST_ADDR_WIDTH 0x1f
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_RESET_ADDR 0x20000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SPI
#define __ALTERA_AVALON_SYSID
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2
#define __ALTMEMDDR2
#define __AVALON_I2C_MASTER_TOP
#define __AVALON_SLAVE_CONDUIT
#define __CMD_FIFO_IF_AVALON
#define __FASTER_INTERFACE
#define __ONE_WIRE_INTERFACE
#define __OXU210HP_IF
#define __TS_FIFO_IF_AVALON
#define __UART_TOP_LEVEL
#define __VL_AVALON_SPI_SLAVE


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "CYCLONEIVE"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart_0"
#define ALT_STDERR_BASE 0x20100
#define ALT_STDERR_DEV jtag_uart_0
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart_0"
#define ALT_STDIN_BASE 0x20100
#define ALT_STDIN_DEV jtag_uart_0
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart_0"
#define ALT_STDOUT_BASE 0x20100
#define ALT_STDOUT_DEV jtag_uart_0
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "ep4c_sopc_system"


/*
 * altmemddr_0 configuration
 *
 */

#define ALTMEMDDR_0_BASE 0x40000000
#define ALTMEMDDR_0_IRQ -1
#define ALTMEMDDR_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ALTMEMDDR_0_NAME "/dev/altmemddr_0"
#define ALTMEMDDR_0_SPAN 67108864
#define ALTMEMDDR_0_TYPE "altmemddr2"
#define ALT_MODULE_CLASS_altmemddr_0 altmemddr2


/*
 * bootloader configuration
 *
 */

#define ALT_MODULE_CLASS_bootloader altera_avalon_onchip_memory2
#define BOOTLOADER_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define BOOTLOADER_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define BOOTLOADER_BASE 0x20000000
#define BOOTLOADER_CONTENTS_INFO ""
#define BOOTLOADER_DUAL_PORT 0
#define BOOTLOADER_GUI_RAM_BLOCK_TYPE "Automatic"
#define BOOTLOADER_INIT_CONTENTS_FILE "bootloader"
#define BOOTLOADER_INIT_MEM_CONTENT 1
#define BOOTLOADER_INSTANCE_ID "NONE"
#define BOOTLOADER_IRQ -1
#define BOOTLOADER_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BOOTLOADER_NAME "/dev/bootloader"
#define BOOTLOADER_NON_DEFAULT_INIT_FILE_ENABLED 1
#define BOOTLOADER_RAM_BLOCK_TYPE "Auto"
#define BOOTLOADER_READ_DURING_WRITE_MODE "DONT_CARE"
#define BOOTLOADER_SIZE_MULTIPLE 1
#define BOOTLOADER_SIZE_VALUE 6144u
#define BOOTLOADER_SPAN 6144
#define BOOTLOADER_TYPE "altera_avalon_onchip_memory2"
#define BOOTLOADER_WRITABLE 1


/*
 * cmd_fifo_if configuration
 *
 */

#define ALT_MODULE_CLASS_cmd_fifo_if cmd_fifo_if_avalon
#define CMD_FIFO_IF_BASE 0x21300
#define CMD_FIFO_IF_IRQ 14
#define CMD_FIFO_IF_IRQ_INTERRUPT_CONTROLLER_ID 0
#define CMD_FIFO_IF_NAME "/dev/cmd_fifo_if"
#define CMD_FIFO_IF_SPAN 16
#define CMD_FIFO_IF_TYPE "cmd_fifo_if_avalon"


/*
 * ddc_eeprom_i2c_master configuration
 *
 */

#define ALT_MODULE_CLASS_ddc_eeprom_i2c_master avalon_i2c_master_top
#define DDC_EEPROM_I2C_MASTER_BASE 0x20a00
#define DDC_EEPROM_I2C_MASTER_IRQ 15
#define DDC_EEPROM_I2C_MASTER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define DDC_EEPROM_I2C_MASTER_NAME "/dev/ddc_eeprom_i2c_master"
#define DDC_EEPROM_I2C_MASTER_SPAN 8
#define DDC_EEPROM_I2C_MASTER_TYPE "avalon_i2c_master_top"


/*
 * ddc_eeprom_pio configuration
 *
 */

#define ALT_MODULE_CLASS_ddc_eeprom_pio altera_avalon_pio
#define DDC_EEPROM_PIO_BASE 0x20500
#define DDC_EEPROM_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define DDC_EEPROM_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DDC_EEPROM_PIO_CAPTURE 1
#define DDC_EEPROM_PIO_DATA_WIDTH 8
#define DDC_EEPROM_PIO_DO_TEST_BENCH_WIRING 0
#define DDC_EEPROM_PIO_DRIVEN_SIM_VALUE 0x0
#define DDC_EEPROM_PIO_EDGE_TYPE "RISING"
#define DDC_EEPROM_PIO_FREQ 72500000u
#define DDC_EEPROM_PIO_HAS_IN 1
#define DDC_EEPROM_PIO_HAS_OUT 1
#define DDC_EEPROM_PIO_HAS_TRI 0
#define DDC_EEPROM_PIO_IRQ 24
#define DDC_EEPROM_PIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define DDC_EEPROM_PIO_IRQ_TYPE "LEVEL"
#define DDC_EEPROM_PIO_NAME "/dev/ddc_eeprom_pio"
#define DDC_EEPROM_PIO_RESET_VALUE 0xc
#define DDC_EEPROM_PIO_SPAN 16
#define DDC_EEPROM_PIO_TYPE "altera_avalon_pio"


/*
 * ddc_master_mem configuration
 *
 */

#define ALT_MODULE_CLASS_ddc_master_mem avalon_slave_conduit
#define DDC_MASTER_MEM_BASE 0x22000
#define DDC_MASTER_MEM_IRQ -1
#define DDC_MASTER_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DDC_MASTER_MEM_NAME "/dev/ddc_master_mem"
#define DDC_MASTER_MEM_SPAN 512
#define DDC_MASTER_MEM_TYPE "avalon_slave_conduit"


/*
 * ddc_slave_mem configuration
 *
 */

#define ALT_MODULE_CLASS_ddc_slave_mem avalon_slave_conduit
#define DDC_SLAVE_MEM_BASE 0x24000
#define DDC_SLAVE_MEM_IRQ -1
#define DDC_SLAVE_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DDC_SLAVE_MEM_NAME "/dev/ddc_slave_mem"
#define DDC_SLAVE_MEM_SPAN 512
#define DDC_SLAVE_MEM_TYPE "avalon_slave_conduit"


/*
 * debug_pio configuration
 *
 */

#define ALT_MODULE_CLASS_debug_pio altera_avalon_pio
#define DEBUG_PIO_BASE 0x20600
#define DEBUG_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define DEBUG_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DEBUG_PIO_CAPTURE 0
#define DEBUG_PIO_DATA_WIDTH 32
#define DEBUG_PIO_DO_TEST_BENCH_WIRING 0
#define DEBUG_PIO_DRIVEN_SIM_VALUE 0x0
#define DEBUG_PIO_EDGE_TYPE "NONE"
#define DEBUG_PIO_FREQ 72500000u
#define DEBUG_PIO_HAS_IN 1
#define DEBUG_PIO_HAS_OUT 1
#define DEBUG_PIO_HAS_TRI 0
#define DEBUG_PIO_IRQ -1
#define DEBUG_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DEBUG_PIO_IRQ_TYPE "NONE"
#define DEBUG_PIO_NAME "/dev/debug_pio"
#define DEBUG_PIO_RESET_VALUE 0x0
#define DEBUG_PIO_SPAN 16
#define DEBUG_PIO_TYPE "altera_avalon_pio"


/*
 * epcs_spi configuration
 *
 */

#define ALT_MODULE_CLASS_epcs_spi altera_avalon_spi
#define EPCS_SPI_BASE 0x20020
#define EPCS_SPI_CLOCKMULT 1
#define EPCS_SPI_CLOCKPHASE 1
#define EPCS_SPI_CLOCKPOLARITY 1
#define EPCS_SPI_CLOCKUNITS "Hz"
#define EPCS_SPI_DATABITS 8
#define EPCS_SPI_DATAWIDTH 16
#define EPCS_SPI_DELAYMULT "1.0E-9"
#define EPCS_SPI_DELAYUNITS "ns"
#define EPCS_SPI_EXTRADELAY 1
#define EPCS_SPI_INSERT_SYNC 1
#define EPCS_SPI_IRQ 18
#define EPCS_SPI_IRQ_INTERRUPT_CONTROLLER_ID 0
#define EPCS_SPI_ISMASTER 1
#define EPCS_SPI_LSBFIRST 0
#define EPCS_SPI_NAME "/dev/epcs_spi"
#define EPCS_SPI_NUMSLAVES 1
#define EPCS_SPI_PREFIX "spi_"
#define EPCS_SPI_SPAN 32
#define EPCS_SPI_SYNC_REG_DEPTH 2
#define EPCS_SPI_TARGETCLOCK 10000000u
#define EPCS_SPI_TARGETSSDELAY "10.0"
#define EPCS_SPI_TYPE "altera_avalon_spi"


/*
 * faster_interface_0 configuration
 *
 */

#define ALT_MODULE_CLASS_faster_interface_0 faster_interface
#define FASTER_INTERFACE_0_BASE 0x1000000
#define FASTER_INTERFACE_0_IRQ 4
#define FASTER_INTERFACE_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define FASTER_INTERFACE_0_NAME "/dev/faster_interface_0"
#define FASTER_INTERFACE_0_SPAN 16777216
#define FASTER_INTERFACE_0_TYPE "faster_interface"


/*
 * gfx_fifo_if configuration
 *
 */

#define ALT_MODULE_CLASS_gfx_fifo_if cmd_fifo_if_avalon
#define GFX_FIFO_IF_BASE 0x21200
#define GFX_FIFO_IF_IRQ 12
#define GFX_FIFO_IF_IRQ_INTERRUPT_CONTROLLER_ID 0
#define GFX_FIFO_IF_NAME "/dev/gfx_fifo_if"
#define GFX_FIFO_IF_SPAN 16
#define GFX_FIFO_IF_TYPE "cmd_fifo_if_avalon"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK TIMER_0
#define ALT_TIMESTAMP_CLK none


/*
 * interrupt_pio configuration
 *
 */

#define ALT_MODULE_CLASS_interrupt_pio altera_avalon_pio
#define INTERRUPT_PIO_BASE 0x20090
#define INTERRUPT_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define INTERRUPT_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define INTERRUPT_PIO_CAPTURE 0
#define INTERRUPT_PIO_DATA_WIDTH 8
#define INTERRUPT_PIO_DO_TEST_BENCH_WIRING 0
#define INTERRUPT_PIO_DRIVEN_SIM_VALUE 0x0
#define INTERRUPT_PIO_EDGE_TYPE "NONE"
#define INTERRUPT_PIO_FREQ 72500000u
#define INTERRUPT_PIO_HAS_IN 1
#define INTERRUPT_PIO_HAS_OUT 1
#define INTERRUPT_PIO_HAS_TRI 0
#define INTERRUPT_PIO_IRQ -1
#define INTERRUPT_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define INTERRUPT_PIO_IRQ_TYPE "NONE"
#define INTERRUPT_PIO_NAME "/dev/interrupt_pio"
#define INTERRUPT_PIO_RESET_VALUE 0x0
#define INTERRUPT_PIO_SPAN 16
#define INTERRUPT_PIO_TYPE "altera_avalon_pio"


/*
 * jtag_uart_0 configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart_0 altera_avalon_jtag_uart
#define JTAG_UART_0_BASE 0x20100
#define JTAG_UART_0_IRQ 1
#define JTAG_UART_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_0_NAME "/dev/jtag_uart_0"
#define JTAG_UART_0_READ_DEPTH 64
#define JTAG_UART_0_READ_THRESHOLD 8
#define JTAG_UART_0_SPAN 8
#define JTAG_UART_0_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_0_WRITE_DEPTH 64
#define JTAG_UART_0_WRITE_THRESHOLD 8


/*
 * lvds_edid_mem configuration
 *
 */

#define ALT_MODULE_CLASS_lvds_edid_mem avalon_slave_conduit
#define LVDS_EDID_MEM_BASE 0x21400
#define LVDS_EDID_MEM_IRQ -1
#define LVDS_EDID_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LVDS_EDID_MEM_NAME "/dev/lvds_edid_mem"
#define LVDS_EDID_MEM_SPAN 512
#define LVDS_EDID_MEM_TYPE "avalon_slave_conduit"


/*
 * lvds_pio configuration
 *
 */

#define ALT_MODULE_CLASS_lvds_pio altera_avalon_pio
#define LVDS_PIO_BASE 0x20700
#define LVDS_PIO_BIT_CLEARING_EDGE_REGISTER 1
#define LVDS_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define LVDS_PIO_CAPTURE 1
#define LVDS_PIO_DATA_WIDTH 8
#define LVDS_PIO_DO_TEST_BENCH_WIRING 0
#define LVDS_PIO_DRIVEN_SIM_VALUE 0x0
#define LVDS_PIO_EDGE_TYPE "ANY"
#define LVDS_PIO_FREQ 72500000u
#define LVDS_PIO_HAS_IN 1
#define LVDS_PIO_HAS_OUT 1
#define LVDS_PIO_HAS_TRI 0
#define LVDS_PIO_IRQ 22
#define LVDS_PIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define LVDS_PIO_IRQ_TYPE "EDGE"
#define LVDS_PIO_NAME "/dev/lvds_pio"
#define LVDS_PIO_RESET_VALUE 0x0
#define LVDS_PIO_SPAN 16
#define LVDS_PIO_TYPE "altera_avalon_pio"


/*
 * m95320 configuration
 *
 */

#define ALT_MODULE_CLASS_m95320 altera_avalon_spi
#define M95320_BASE 0x20d00
#define M95320_CLOCKMULT 1
#define M95320_CLOCKPHASE 0
#define M95320_CLOCKPOLARITY 0
#define M95320_CLOCKUNITS "Hz"
#define M95320_DATABITS 8
#define M95320_DATAWIDTH 16
#define M95320_DELAYMULT "1.0E-9"
#define M95320_DELAYUNITS "ns"
#define M95320_EXTRADELAY 1
#define M95320_INSERT_SYNC 0
#define M95320_IRQ 11
#define M95320_IRQ_INTERRUPT_CONTROLLER_ID 0
#define M95320_ISMASTER 1
#define M95320_LSBFIRST 0
#define M95320_NAME "/dev/m95320"
#define M95320_NUMSLAVES 1
#define M95320_PREFIX "spi_"
#define M95320_SPAN 32
#define M95320_SYNC_REG_DEPTH 2
#define M95320_TARGETCLOCK 10000000u
#define M95320_TARGETSSDELAY "30.0"
#define M95320_TYPE "altera_avalon_spi"


/*
 * mcu_pio configuration
 *
 */

#define ALT_MODULE_CLASS_mcu_pio altera_avalon_pio
#define MCU_PIO_BASE 0x200b0
#define MCU_PIO_BIT_CLEARING_EDGE_REGISTER 1
#define MCU_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define MCU_PIO_CAPTURE 1
#define MCU_PIO_DATA_WIDTH 8
#define MCU_PIO_DO_TEST_BENCH_WIRING 0
#define MCU_PIO_DRIVEN_SIM_VALUE 0x0
#define MCU_PIO_EDGE_TYPE "ANY"
#define MCU_PIO_FREQ 72500000u
#define MCU_PIO_HAS_IN 1
#define MCU_PIO_HAS_OUT 1
#define MCU_PIO_HAS_TRI 0
#define MCU_PIO_IRQ 2
#define MCU_PIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define MCU_PIO_IRQ_TYPE "EDGE"
#define MCU_PIO_NAME "/dev/mcu_pio"
#define MCU_PIO_RESET_VALUE 0x0
#define MCU_PIO_SPAN 16
#define MCU_PIO_TYPE "altera_avalon_pio"


/*
 * mcu_spi configuration
 *
 */

#define ALT_MODULE_CLASS_mcu_spi vl_avalon_spi_slave
#define MCU_SPI_BASE 0x20140
#define MCU_SPI_IRQ 7
#define MCU_SPI_IRQ_INTERRUPT_CONTROLLER_ID 0
#define MCU_SPI_NAME "/dev/mcu_spi"
#define MCU_SPI_SPAN 64
#define MCU_SPI_TYPE "vl_avalon_spi_slave"


/*
 * one_wire_interface_0 configuration
 *
 */

#define ALT_MODULE_CLASS_one_wire_interface_0 one_wire_interface
#define ONE_WIRE_INTERFACE_0_BASE 0x20040
#define ONE_WIRE_INTERFACE_0_IRQ -1
#define ONE_WIRE_INTERFACE_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONE_WIRE_INTERFACE_0_NAME "/dev/one_wire_interface_0"
#define ONE_WIRE_INTERFACE_0_SPAN 64
#define ONE_WIRE_INTERFACE_0_TYPE "one_wire_interface"


/*
 * oxu210hp_if_0 configuration
 *
 */

#define ALT_MODULE_CLASS_oxu210hp_if_0 oxu210hp_if
#define OXU210HP_IF_0_BASE 0x0
#define OXU210HP_IF_0_IRQ 9
#define OXU210HP_IF_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define OXU210HP_IF_0_NAME "/dev/oxu210hp_if_0"
#define OXU210HP_IF_0_SPAN 131072
#define OXU210HP_IF_0_TYPE "oxu210hp_if"


/*
 * oxu210hp_int configuration
 *
 */

#define ALT_MODULE_CLASS_oxu210hp_int altera_avalon_pio
#define OXU210HP_INT_BASE 0x21100
#define OXU210HP_INT_BIT_CLEARING_EDGE_REGISTER 0
#define OXU210HP_INT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define OXU210HP_INT_CAPTURE 1
#define OXU210HP_INT_DATA_WIDTH 1
#define OXU210HP_INT_DO_TEST_BENCH_WIRING 0
#define OXU210HP_INT_DRIVEN_SIM_VALUE 0x0
#define OXU210HP_INT_EDGE_TYPE "ANY"
#define OXU210HP_INT_FREQ 72500000u
#define OXU210HP_INT_HAS_IN 1
#define OXU210HP_INT_HAS_OUT 1
#define OXU210HP_INT_HAS_TRI 0
#define OXU210HP_INT_IRQ 10
#define OXU210HP_INT_IRQ_INTERRUPT_CONTROLLER_ID 0
#define OXU210HP_INT_IRQ_TYPE "EDGE"
#define OXU210HP_INT_NAME "/dev/oxu210hp_int"
#define OXU210HP_INT_RESET_VALUE 0x0
#define OXU210HP_INT_SPAN 16
#define OXU210HP_INT_TYPE "altera_avalon_pio"


/*
 * reset_pio configuration
 *
 */

#define ALT_MODULE_CLASS_reset_pio altera_avalon_pio
#define RESET_PIO_BASE 0x20800
#define RESET_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define RESET_PIO_BIT_MODIFYING_OUTPUT_REGISTER 1
#define RESET_PIO_CAPTURE 0
#define RESET_PIO_DATA_WIDTH 8
#define RESET_PIO_DO_TEST_BENCH_WIRING 0
#define RESET_PIO_DRIVEN_SIM_VALUE 0x0
#define RESET_PIO_EDGE_TYPE "NONE"
#define RESET_PIO_FREQ 72500000u
#define RESET_PIO_HAS_IN 0
#define RESET_PIO_HAS_OUT 1
#define RESET_PIO_HAS_TRI 0
#define RESET_PIO_IRQ -1
#define RESET_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define RESET_PIO_IRQ_TYPE "NONE"
#define RESET_PIO_NAME "/dev/reset_pio"
#define RESET_PIO_RESET_VALUE 0xff
#define RESET_PIO_SPAN 32
#define RESET_PIO_TYPE "altera_avalon_pio"


/*
 * sdvo_edid_mem configuration
 *
 */

#define ALT_MODULE_CLASS_sdvo_edid_mem avalon_slave_conduit
#define SDVO_EDID_MEM_BASE 0x21800
#define SDVO_EDID_MEM_IRQ -1
#define SDVO_EDID_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDVO_EDID_MEM_NAME "/dev/sdvo_edid_mem"
#define SDVO_EDID_MEM_SPAN 512
#define SDVO_EDID_MEM_TYPE "avalon_slave_conduit"


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid
#define SYSID_BASE 0x20000
#define SYSID_ID 0u
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1322046977u
#define SYSID_TYPE "altera_avalon_sysid"


/*
 * tfp410_i2c_master configuration
 *
 */

#define ALT_MODULE_CLASS_tfp410_i2c_master avalon_i2c_master_top
#define TFP410_I2C_MASTER_BASE 0x20008
#define TFP410_I2C_MASTER_IRQ 17
#define TFP410_I2C_MASTER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TFP410_I2C_MASTER_NAME "/dev/tfp410_i2c_master"
#define TFP410_I2C_MASTER_SPAN 8
#define TFP410_I2C_MASTER_TYPE "avalon_i2c_master_top"


/*
 * timer_0 configuration
 *
 */

#define ALT_MODULE_CLASS_timer_0 altera_avalon_timer
#define TIMER_0_ALWAYS_RUN 0
#define TIMER_0_BASE 0x20200
#define TIMER_0_COUNTER_SIZE 32
#define TIMER_0_FIXED_PERIOD 0
#define TIMER_0_FREQ 72500000u
#define TIMER_0_IRQ 0
#define TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_0_LOAD_VALUE 72499ull
#define TIMER_0_MULT 0.0010
#define TIMER_0_NAME "/dev/timer_0"
#define TIMER_0_PERIOD 1
#define TIMER_0_PERIOD_UNITS "ms"
#define TIMER_0_RESET_OUTPUT 0
#define TIMER_0_SNAPSHOT 1
#define TIMER_0_SPAN 32
#define TIMER_0_TICKS_PER_SEC 1000u
#define TIMER_0_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_0_TYPE "altera_avalon_timer"


/*
 * timer_60Hz configuration
 *
 */

#define ALT_MODULE_CLASS_timer_60Hz altera_avalon_timer
#define TIMER_60HZ_ALWAYS_RUN 1
#define TIMER_60HZ_BASE 0x20300
#define TIMER_60HZ_COUNTER_SIZE 32
#define TIMER_60HZ_FIXED_PERIOD 1
#define TIMER_60HZ_FREQ 72500000u
#define TIMER_60HZ_IRQ 3
#define TIMER_60HZ_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_60HZ_LOAD_VALUE 1208357ull
#define TIMER_60HZ_MULT 1.0E-6
#define TIMER_60HZ_NAME "/dev/timer_60Hz"
#define TIMER_60HZ_PERIOD 16667
#define TIMER_60HZ_PERIOD_UNITS "us"
#define TIMER_60HZ_RESET_OUTPUT 0
#define TIMER_60HZ_SNAPSHOT 0
#define TIMER_60HZ_SPAN 32
#define TIMER_60HZ_TICKS_PER_SEC 60u
#define TIMER_60HZ_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_60HZ_TYPE "altera_avalon_timer"


/*
 * ts_fifo_if_avalon_0 configuration
 *
 */

#define ALT_MODULE_CLASS_ts_fifo_if_avalon_0 ts_fifo_if_avalon
#define TS_FIFO_IF_AVALON_0_BASE 0x20e00
#define TS_FIFO_IF_AVALON_0_IRQ -1
#define TS_FIFO_IF_AVALON_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TS_FIFO_IF_AVALON_0_NAME "/dev/ts_fifo_if_avalon_0"
#define TS_FIFO_IF_AVALON_0_SPAN 8
#define TS_FIFO_IF_AVALON_0_TYPE "ts_fifo_if_avalon"


/*
 * ts_pio configuration
 *
 */

#define ALT_MODULE_CLASS_ts_pio altera_avalon_pio
#define TS_PIO_BASE 0x200a0
#define TS_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define TS_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define TS_PIO_CAPTURE 0
#define TS_PIO_DATA_WIDTH 8
#define TS_PIO_DO_TEST_BENCH_WIRING 0
#define TS_PIO_DRIVEN_SIM_VALUE 0x0
#define TS_PIO_EDGE_TYPE "NONE"
#define TS_PIO_FREQ 72500000u
#define TS_PIO_HAS_IN 1
#define TS_PIO_HAS_OUT 1
#define TS_PIO_HAS_TRI 0
#define TS_PIO_IRQ -1
#define TS_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TS_PIO_IRQ_TYPE "NONE"
#define TS_PIO_NAME "/dev/ts_pio"
#define TS_PIO_RESET_VALUE 0x0
#define TS_PIO_SPAN 16
#define TS_PIO_TYPE "altera_avalon_pio"


/*
 * uart_pc configuration
 *
 */

#define ALT_MODULE_CLASS_uart_pc uart_top_level
#define UART_PC_BASE 0x21000
#define UART_PC_IRQ 8
#define UART_PC_IRQ_INTERRUPT_CONTROLLER_ID 0
#define UART_PC_NAME "/dev/uart_pc"
#define UART_PC_SPAN 32
#define UART_PC_TYPE "uart_top_level"


/*
 * uart_ts configuration
 *
 */

#define ALT_MODULE_CLASS_uart_ts uart_top_level
#define UART_TS_BASE 0x20f00
#define UART_TS_IRQ 6
#define UART_TS_IRQ_INTERRUPT_CONTROLLER_ID 0
#define UART_TS_NAME "/dev/uart_ts"
#define UART_TS_SPAN 32
#define UART_TS_TYPE "uart_top_level"


/*
 * usb_pio configuration
 *
 */

#define ALT_MODULE_CLASS_usb_pio altera_avalon_pio
#define USB_PIO_BASE 0x20080
#define USB_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define USB_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define USB_PIO_CAPTURE 0
#define USB_PIO_DATA_WIDTH 4
#define USB_PIO_DO_TEST_BENCH_WIRING 0
#define USB_PIO_DRIVEN_SIM_VALUE 0x0
#define USB_PIO_EDGE_TYPE "NONE"
#define USB_PIO_FREQ 72500000u
#define USB_PIO_HAS_IN 0
#define USB_PIO_HAS_OUT 1
#define USB_PIO_HAS_TRI 0
#define USB_PIO_IRQ -1
#define USB_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define USB_PIO_IRQ_TYPE "NONE"
#define USB_PIO_NAME "/dev/usb_pio"
#define USB_PIO_RESET_VALUE 0x0
#define USB_PIO_SPAN 16
#define USB_PIO_TYPE "altera_avalon_pio"


/*
 * vai_i2c_master configuration
 *
 */

#define ALT_MODULE_CLASS_vai_i2c_master avalon_i2c_master_top
#define VAI_I2C_MASTER_BASE 0x20b00
#define VAI_I2C_MASTER_IRQ 5
#define VAI_I2C_MASTER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VAI_I2C_MASTER_NAME "/dev/vai_i2c_master"
#define VAI_I2C_MASTER_SPAN 8
#define VAI_I2C_MASTER_TYPE "avalon_i2c_master_top"


/*
 * veb_i2c_master configuration
 *
 */

#define ALT_MODULE_CLASS_veb_i2c_master avalon_i2c_master_top
#define VEB_I2C_MASTER_BASE 0x20c00
#define VEB_I2C_MASTER_IRQ 13
#define VEB_I2C_MASTER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VEB_I2C_MASTER_NAME "/dev/veb_i2c_master"
#define VEB_I2C_MASTER_SPAN 8
#define VEB_I2C_MASTER_TYPE "avalon_i2c_master_top"


/*
 * version_pio configuration
 *
 */

#define ALT_MODULE_CLASS_version_pio altera_avalon_pio
#define VERSION_PIO_BASE 0x20900
#define VERSION_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define VERSION_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define VERSION_PIO_CAPTURE 0
#define VERSION_PIO_DATA_WIDTH 32
#define VERSION_PIO_DO_TEST_BENCH_WIRING 0
#define VERSION_PIO_DRIVEN_SIM_VALUE 0x0
#define VERSION_PIO_EDGE_TYPE "NONE"
#define VERSION_PIO_FREQ 72500000u
#define VERSION_PIO_HAS_IN 1
#define VERSION_PIO_HAS_OUT 1
#define VERSION_PIO_HAS_TRI 0
#define VERSION_PIO_IRQ -1
#define VERSION_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VERSION_PIO_IRQ_TYPE "NONE"
#define VERSION_PIO_NAME "/dev/version_pio"
#define VERSION_PIO_RESET_VALUE 0x0
#define VERSION_PIO_SPAN 16
#define VERSION_PIO_TYPE "altera_avalon_pio"


/*
 * vi_0_pio configuration
 *
 */

#define ALT_MODULE_CLASS_vi_0_pio altera_avalon_pio
#define VI_0_PIO_BASE 0x20400
#define VI_0_PIO_BIT_CLEARING_EDGE_REGISTER 1
#define VI_0_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define VI_0_PIO_CAPTURE 1
#define VI_0_PIO_DATA_WIDTH 8
#define VI_0_PIO_DO_TEST_BENCH_WIRING 0
#define VI_0_PIO_DRIVEN_SIM_VALUE 0x0
#define VI_0_PIO_EDGE_TYPE "ANY"
#define VI_0_PIO_FREQ 72500000u
#define VI_0_PIO_HAS_IN 1
#define VI_0_PIO_HAS_OUT 1
#define VI_0_PIO_HAS_TRI 0
#define VI_0_PIO_IRQ 20
#define VI_0_PIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VI_0_PIO_IRQ_TYPE "EDGE"
#define VI_0_PIO_NAME "/dev/vi_0_pio"
#define VI_0_PIO_RESET_VALUE 0x0
#define VI_0_PIO_SPAN 16
#define VI_0_PIO_TYPE "altera_avalon_pio"


/*
 * vi_1_pio configuration
 *
 */

#define ALT_MODULE_CLASS_vi_1_pio altera_avalon_pio
#define VI_1_PIO_BASE 0x20480
#define VI_1_PIO_BIT_CLEARING_EDGE_REGISTER 1
#define VI_1_PIO_BIT_MODIFYING_OUTPUT_REGISTER 1
#define VI_1_PIO_CAPTURE 1
#define VI_1_PIO_DATA_WIDTH 8
#define VI_1_PIO_DO_TEST_BENCH_WIRING 0
#define VI_1_PIO_DRIVEN_SIM_VALUE 0x0
#define VI_1_PIO_EDGE_TYPE "ANY"
#define VI_1_PIO_FREQ 72500000u
#define VI_1_PIO_HAS_IN 1
#define VI_1_PIO_HAS_OUT 1
#define VI_1_PIO_HAS_TRI 0
#define VI_1_PIO_IRQ 19
#define VI_1_PIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VI_1_PIO_IRQ_TYPE "LEVEL"
#define VI_1_PIO_NAME "/dev/vi_1_pio"
#define VI_1_PIO_RESET_VALUE 0x0
#define VI_1_PIO_SPAN 32
#define VI_1_PIO_TYPE "altera_avalon_pio"


/*
 * vo_pio configuration
 *
 */

#define ALT_MODULE_CLASS_vo_pio altera_avalon_pio
#define VO_PIO_BASE 0x20010
#define VO_PIO_BIT_CLEARING_EDGE_REGISTER 1
#define VO_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define VO_PIO_CAPTURE 1
#define VO_PIO_DATA_WIDTH 8
#define VO_PIO_DO_TEST_BENCH_WIRING 0
#define VO_PIO_DRIVEN_SIM_VALUE 0x0
#define VO_PIO_EDGE_TYPE "ANY"
#define VO_PIO_FREQ 72500000u
#define VO_PIO_HAS_IN 1
#define VO_PIO_HAS_OUT 1
#define VO_PIO_HAS_TRI 0
#define VO_PIO_IRQ 21
#define VO_PIO_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VO_PIO_IRQ_TYPE "EDGE"
#define VO_PIO_NAME "/dev/vo_pio"
#define VO_PIO_RESET_VALUE 0x0
#define VO_PIO_SPAN 16
#define VO_PIO_TYPE "altera_avalon_pio"

#endif /* __SYSTEM_H_ */
