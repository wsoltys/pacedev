#------------------------------------------------------------------------------
#              VARIABLES APPENDED TO BY INCLUDED MAKEFILE FRAGMENTS
#------------------------------------------------------------------------------

# List of include directories for -I compiler option (-I added when used).
# Includes the BSP.
ALT_INCLUDE_DIRS :=

# List of library directories for -L linker option (-L added when used).
# Includes the BSP.
ALT_LIBRARY_DIRS :=

# List of library names for -l linker option (-l added when used).
# Includes the BSP.
ALT_LIBRARY_NAMES :=

# List of library names for -msys-lib linker option (-msys-lib added when used).
# These are libraries that might be located in the BSP and depend on the BSP
# library, or vice versa
ALT_BSP_DEP_LIBRARY_NAMES :=

# List of dependencies for the linker.  This is usually the full pathname
# of each library (*.a) file.
# Includes the BSP.
ALT_LDDEPS :=

# List of root library directories that support running make to build them.
# Includes the BSP and any ALT libraries.
MAKEABLE_LIBRARY_ROOT_DIRS :=

# Generic flags passed to the compiler for different types of input files.
ALT_CFLAGS :=
ALT_CXXFLAGS :=
ALT_CPPFLAGS :=
ALT_ASFLAGS :=
ALT_LDFLAGS :=

#------------------------------------------------------------------------------
#                                 TOOLS
#------------------------------------------------------------------------------
CROSS_COMPILE := nios2-elf-
CC      := $(CROSS_COMPILE)gcc -xc
CXX     := $(CROSS_COMPILE)gcc -xc++
AS      := $(CROSS_COMPILE)gcc
AR      := $(CROSS_COMPILE)ar
LD      := $(CROSS_COMPILE)g++
NM      := $(CROSS_COMPILE)nm
RM      := rm -f
OBJDUMP := $(CROSS_COMPILE)objdump
OBJCOPY := $(CROSS_COMPILE)objcopy
STACKREPORT := nios2-stackreport
DOWNLOAD := nios2-download
FLASHPROG := nios2-flash-programmer
ELFPATCH := nios2-elf-insert

MKDIR := mkdir -p
ECHO := echo


#------------------------------------------------------------------------------
#                         The adjust-path macro
# 
# If COMSPEC is defined, Make is launched from Windows through
# Cygwin.  This adjust-path macro will call 'cygpath -u' on all
# paths to ensure they are readable by Make.
#
# If COMSPEC is not defined, Make is launched from *nix, and no adjustment
# is necessary
#------------------------------------------------------------------------------

ifdef COMSPEC
	adjust-path = $(shell cygpath -u "$1")
	adjust-path-mixed = $(shell cygpath -m "$1")
else
	adjust-path = $1
	adjust-path-mixed = $1
endif

#------------------------------------------------------------------------------
#                           DEFAULT TARGET
#------------------------------------------------------------------------------

# Put "all" rule before included makefile fragments because they may
# define rules and we don't want one of those to become the default rule.
.PHONY : all

all:
	@$(ECHO) [$(APP_NAME) build complete]

all : build_pre_process libs app build_post_process 


#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#                           GENERATED SETTINGS START                         v
#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

#START GENERATED

# The following TYPE comment allows tools to identify the 'type' of target this 
# makefile is associated with. 
# TYPE: APP_MAKEFILE

# This following VERSION comment indicates the version of the tool used to 
# generate this makefile. A makefile variable is provided for VERSION as well. 
# ACDS_VERSION: 9.1sp2
ACDS_VERSION := 9.1sp2

# This following BUILD_NUMBER comment indicates the build number of the tool 
# used to generate this makefile. 
# BUILD_NUMBER: 350


# Define path to the application ELF. 
# It may be used by the makefile fragments so is defined before including them. 
# 
ELF := ep4c_nios.elf

# Paths to C, C++, and assembly source files.
C_SRCS :=
CXX_SRCS += ep4c_nios.cpp
CXX_SRCS += i2c_master.cpp
ASM_SRCS :=


# Path to root of object file tree.
OBJ_ROOT_DIR := obj

# Options to control objdump.
CREATE_OBJDUMP := 0
OBJDUMP_INCLUDE_SOURCE := 1
OBJDUMP_FULL_CONTENTS := 0

# Options to enable/disable optional files.
CREATE_ELF_DERIVED_FILES := 0
CREATE_LINKER_MAP := 1

# Common arguments for ALT_CFLAGSs
APP_CFLAGS_DEFINED_SYMBOLS :=
APP_CFLAGS_UNDEFINED_SYMBOLS :=
APP_CFLAGS_OPTIMIZATION := -O0
APP_CFLAGS_DEBUG_LEVEL := -g
APP_CFLAGS_WARNINGS := -Wall
APP_CFLAGS_USER_FLAGS :=

APP_ASFLAGS_USER :=

# Linker options that have default values assigned later if not
# assigned here.
LINKER_SCRIPT :=
CRT0 :=
SYS_LIB :=

# Define path to the root of the BSP.
BSP_ROOT_DIR := ../ep4c_nios_bsp

# List of application specific include directories, library directories and library names
APP_INCLUDE_DIRS :=
APP_LIBRARY_DIRS :=
APP_LIBRARY_NAMES :=

# Pre- and post- processor settings.
BUILD_PRE_PROCESS :=
BUILD_POST_PROCESS :=

QUARTUS_PROJECT_DIR := ../../


#END GENERATED

#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#                            GENERATED SETTINGS END                           ^
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


#------------------------------------------------------------------------------
#                 VARIABLES DEPENDENT ON GENERATED CONTENT
#------------------------------------------------------------------------------

ifeq ($(BSP_ROOT_DIR),)
$(error Edit Makefile and provide a value for BSP_ROOT_DIR)
endif

ifeq ($(wildcard $(BSP_ROOT_DIR)),)
$(error BSP directory does not exist: $(BSP_ROOT_DIR))
endif

# Define absolute path to the root of the BSP.
ABS_BSP_ROOT_DIR := $(call adjust-path-mixed,$(shell cd "$(BSP_ROOT_DIR)"; pwd))

# Include makefile fragments.  Define variable ALT_LIBRARY_ROOT_DIR before
# including each makefile fragment so that it knows the path to itself.
BSP_INCLUDE_FILE := $(BSP_ROOT_DIR)/public.mk
ALT_LIBRARY_ROOT_DIR := $(BSP_ROOT_DIR)
include $(BSP_INCLUDE_FILE)
# C2H will need this to touch the BSP public.mk and avoid the sopc file out-of-date error during a BSP make
ABS_BSP_INCLUDE_FILE := $(ABS_BSP_ROOT_DIR)/public.mk


# If the BSP public.mk indicates that ALT_SIM_OPTIMIZE is set, rename the ELF 
# by prefixing it with RUN_ON_HDL_SIMULATOR_ONLY_.  
ifneq ($(filter -DALT_SIM_OPTIMIZE,$(ALT_CPPFLAGS)),)
ELF := RUN_ON_HDL_SIMULATOR_ONLY_$(ELF)
endif


# If the BSP public.mk indicates that ALT_PROVIDE_GMON is set, add option to download_elf target
ifneq ($(filter -DALT_PROVIDE_GMON,$(ALT_CPPFLAGS)),)
GMON_OUT_FILENAME := gmon.out
WRITE_GMON_OPTION := --write-gmon $(GMON_OUT_FILENAME)
endif

# Name of ELF application.
APP_NAME := $(basename $(ELF))

# Set to defaults if variables not already defined in settings.
ifeq ($(LINKER_SCRIPT),)
LINKER_SCRIPT := $(BSP_LINKER_SCRIPT)
endif
ifeq ($(CRT0),)
CRT0 := $(BSP_CRT0)
endif
ifeq ($(SYS_LIB),)
SYS_LIB := $(BSP_SYS_LIB)
endif

OBJDUMP_NAME := $(APP_NAME).objdump
OBJDUMP_FLAGS := --disassemble --syms --all-header
ifeq ($(OBJDUMP_INCLUDE_SOURCE),1)
OBJDUMP_FLAGS += --source
endif
ifeq ($(OBJDUMP_FULL_CONTENTS),1)
OBJDUMP_FLAGS += --full-contents
endif

# Create list of linker dependencies (*.a files).
APP_LDDEPS := $(ALT_LDDEPS) $(LDDEPS)

# Take lists and add required prefixes.
APP_INC_DIRS := $(addprefix -I, $(ALT_INCLUDE_DIRS) $(APP_INCLUDE_DIRS) $(INC_DIRS))
ASM_INC_PREFIX := -Wa,-I
APP_ASM_INC_DIRS := $(addprefix $(ASM_INC_PREFIX), $(ALT_INCLUDE_DIRS) $(APP_INCLUDE_DIRS) $(INC_DIRS))
APP_LIB_DIRS := $(addprefix -L, $(ALT_LIBRARY_DIRS) $(APP_LIBRARY_DIRS) $(LIB_DIRS))
APP_LIBS := $(addprefix -l, $(ALT_LIBRARY_NAMES) $(APP_LIBRARY_NAMES) $(LIBS))
APP_BSP_DEP_LIBS := $(addprefix -msys-lib=, $(ALT_BSP_DEP_LIBRARY_NAMES))

# Arguments for the C preprocessor, C/C++ compiler, assembler, and linker.
APP_CFLAGS := $(APP_CFLAGS_DEFINED_SYMBOLS) \
              $(APP_CFLAGS_UNDEFINED_SYMBOLS) \
              $(APP_CFLAGS_OPTIMIZATION) \
              $(APP_CFLAGS_DEBUG_LEVEL) \
              $(APP_CFLAGS_WARNINGS) \
              $(APP_CFLAGS_USER_FLAGS) \
              $(ALT_CFLAGS) \
              $(CFLAGS)

# Arguments only for the C++ compiler.
APP_CXXFLAGS := $(ALT_CXXFLAGS) $(CXXFLAGS)

# Arguments only for the C preprocessor.
# Prefix each include directory with -I.
APP_CPPFLAGS := $(APP_INC_DIRS) \
                $(ALT_CPPFLAGS) \
                $(CPPFLAGS)

# Arguments only for the assembler.
APP_ASFLAGS := $(APP_ASM_INC_DIRS) \
               $(ALT_ASFLAGS) \
               $(APP_ASFLAGS_USER) \
               $(ASFLAGS)

# Arguments only for the linker.
APP_LDFLAGS := 

ifneq ($(LINKER_SCRIPT),)
APP_LDFLAGS += -T'$(LINKER_SCRIPT)'
endif

ifneq ($(CRT0),)
APP_LDFLAGS += -msys-crt0='$(CRT0)'
endif

ifneq ($(SYS_LIB),)
APP_LDFLAGS += -msys-lib=$(SYS_LIB)
endif

APP_LDFLAGS += \
           $(APP_LIB_DIRS) \
           $(ALT_LDFLAGS) \
           $(LDFLAGS)

LINKER_MAP_NAME := $(APP_NAME).map
ifeq ($(CREATE_LINKER_MAP), 1)
APP_LDFLAGS += -Wl,-Map=$(LINKER_MAP_NAME)
endif

# If SOPC_NAME is not set and QUARTUS_PROJECT_DIR is set, then derive SOPC_NAME.
ifeq ($(SOPC_NAME),)
ifneq ($(QUARTUS_PROJECT_DIR),)
SOPC_NAME := $(basename $(notdir $(wildcard $(QUARTUS_PROJECT_DIR)/*.sopcinfo)))
endif
endif

# If JDI_FILE is not set and QUARTUS_PROJECT_DIR is set, then derive JDI_FILE.
ifeq ($(JDI_FILE),)
ifneq ($(QUARTUS_PROJECT_DIR),)
JDI_FILE := $(wildcard $(QUARTUS_PROJECT_DIR)/*.jdi)
endif
endif


#------------------------------------------------------------------------------
#           MAKEFILE INCLUDES DEPENDENT ON GENERATED CONTENT
#------------------------------------------------------------------------------
# mem_init.mk is a generated makefile fragment. This file defines all targets
# used to generate HDL initialization simulation files and pre-initialized
# onchip memory files.
MEM_INIT_FILE :=  $(BSP_ROOT_DIR)/mem_init.mk
include $(MEM_INIT_FILE)

# Create list of object files to be built using the list of source files.
# The source file hierarchy is preserved in the object tree.
# The supported file extensions are:
#
# .c            - for C files
# .cxx .cc .cpp - for C++ files
# .S .s         - for assembler files
#
# Handle source files specified by --src-dir & --src-rdir differently, to
# save some processing time in calling the adjust-path macro.


OBJ_LIST := $(sort $(C_SRCS:.c=.o)  \
              $(patsubst %.cxx, %.o,                              \
                $(patsubst %.cc, %.o,                             \
                  $(patsubst %.cpp, %.o, $(CXX_SRCS))))           \
              $(patsubst %.S, %.o, $(patsubst %.s, %.o, $(ASM_SRCS))))

SDIR_OBJ_LIST := $(sort $(SDIR_C_SRCS:.c=.o)  \
              $(patsubst %.cxx, %.o,                              \
                $(patsubst %.cc, %.o,                             \
                  $(patsubst %.cpp, %.o, $(SDIR_CXX_SRCS))))           \
              $(patsubst %.S, %.o, $(patsubst %.s, %.o, $(SDIR_ASM_SRCS))))

# Relative-pathed objects that being with "../" are handled differently.
#
# Regular objects are created as 
#   $(OBJ_ROOT_DIR)/<path>/<filename>.o
# where the path structure is maintained under the obj directory.  This
# applies for both absolute and relative paths; in the absolute path
# case this means the entire source path will be recreated under the obj
# directory.  This is done to allow two source files with the same name
# to be included as part of the project.
#
# Note: On Cygwin, the path recreated under the obj directory will be 
# the cygpath -u output path.
#
# Relative-path objects that begin with "../" cause problems under this 
# scheme, as $(OBJ_ROOT_DIR)/../<rest of path>/ can potentially put the object
# files anywhere in the system, creating clutter and polluting the source tree.
# As such, their paths are flattened - the object file created will be 
# $(OBJ_ROOT_DIR)/<filename>.o.  Due to this, two files specified with 
# "../" in the beginning cannot have the same name in the project.  VPATH 
# will be set for these sources to allow make to relocate the source file 
# via %.o rules.
#
# The following lines separate the object list into the flatten and regular
# lists, and then handles them as appropriate.

FLATTEN_OBJ_LIST += $(strip $(foreach s,$(OBJ_LIST),$(if $(filter ../%,$s),$s)))
REGULAR_OBJ_LIST += $(filter-out $(FLATTEN_OBJ_LIST),$(OBJ_LIST))

FLATTEN_APP_OBJS := $(addprefix $(OBJ_ROOT_DIR)/, \
			$(foreach s,$(FLATTEN_OBJ_LIST),$(notdir $s)))

FLATTEN_SDIR_OBJ_LIST += $(strip $(foreach s,$(SDIR_OBJ_LIST),$(if $(filter ../%,$s),$s)))
REGULAR_SDIR_OBJ_LIST += $(filter-out $(FLATTEN_SDIR_OBJ_LIST),$(SDIR_OBJ_LIST))

FLATTEN_SDIR_APP_OBJS := $(addprefix $(OBJ_ROOT_DIR)/, \
			$(foreach s,$(FLATTEN_SDIR_OBJ_LIST),$(notdir $s)))

VPATH := $(sort $(dir $(FLATTEN_OBJ_LIST)) $(dir $(FLATTEN_SDIR_OBJ_LIST)))

APP_OBJS := $(addprefix $(OBJ_ROOT_DIR)/, \
		$(foreach s,$(REGULAR_OBJ_LIST),$(call adjust-path,$s))) \
            $(addprefix $(OBJ_ROOT_DIR)/, \
		$(REGULAR_SDIR_OBJ_LIST)) \
	    $(FLATTEN_APP_OBJS) $(FLATTEN_SDIR_APP_OBJS)

# Add any extra user-provided object files.
APP_OBJS += $(OBJS)

# Create list of dependancy files for each object file.
APP_DEPS := $(APP_OBJS:.o=.d)

# Patch the Elf file with system specific information

# Patch the Elf with the name of the sopc system
ifneq ($(SOPC_NAME),)
ELF_PATCH_FLAG += --sopc_system_name $(SOPC_NAME)
endif

# Patch the Elf with the absolute path to the Quartus Project Directory
ifneq ($(QUARTUS_PROJECT_DIR),)
ABS_QUARTUS_PROJECT_DIR := $(call adjust-path-mixed,$(shell cd "$(QUARTUS_PROJECT_DIR)"; pwd))
ELF_PATCH_FLAG += --quartus_project_dir "$(ABS_QUARTUS_PROJECT_DIR)"
endif

# Patch the Elf and download args with the JDI_FILE if specified
ifneq ($(wildcard $(JDI_FILE)),)
ELF_PATCH_FLAG += --jdi $(JDI_FILE)
DOWNLOAD_JDI_FLAG := --jdi $(JDI_FILE)
endif

# Use the DOWNLOAD_CABLE variable to specify which JTAG cable to use. 
# This is not needed if you only have one cable.
ifneq ($(DOWNLOAD_CABLE),)
DOWNLOAD_CABLE_FLAG := --cable '$(DOWNLOAD_CABLE)'
endif

#------------------------------------------------------------------------------
#                           BUILD PRE/POST PROCESS
#------------------------------------------------------------------------------
build_pre_process :
	$(BUILD_PRE_PROCESS)

build_post_process :
	$(BUILD_POST_PROCESS)

.PHONY: build_pre_process build_post_process

#------------------------------------------------------------------------------
#                     PATTERN RULES TO BUILD OBJECTS
#------------------------------------------------------------------------------

$(OBJ_ROOT_DIR)/%.o: %.c
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CC) -MP -MMD -c $(APP_CPPFLAGS) $(APP_CFLAGS) -o $@ $<
	$(CC_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.cpp
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -MP -MMD -c $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<
	$(CXX_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.cc
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -MP -MMD -c $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<
	$(CXX_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.cxx
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -MP -MMD -c $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<
	$(CXX_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.S
	@$(ECHO) Info: Assembling $< to $@
	@$(MKDIR) $(@D)
	$(AS) -MP -MMD -c $(APP_CPPFLAGS) $(APP_CFLAGS) $(APP_ASFLAGS) -o $@ $<
	$(AS_POST_PROCESS)

$(OBJ_ROOT_DIR)/%.o: %.s
	@$(ECHO) Info: Assembling $< to $@
	@$(MKDIR) $(@D)
	$(AS) -MP -MMD -c $(APP_CFLAGS) $(APP_ASFLAGS) -o $@ $<
	$(AS_POST_PROCESS)

#------------------------------------------------------------------------------
#                     PATTERN RULES TO INTERMEDIATE FILES
#------------------------------------------------------------------------------

$(OBJ_ROOT_DIR)/%.s: %.c
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CC) -S $(APP_CPPFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.s: %.cpp
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -S $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.s: %.cc
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -S $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.s: %.cxx
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -S $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.c
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CC) -E $(APP_CPPFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.cpp
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -E $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.cc
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -E $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<

$(OBJ_ROOT_DIR)/%.i: %.cxx
	@$(ECHO) Info: Compiling $< to $@
	@$(MKDIR) $(@D)
	$(CXX) -E $(APP_CPPFLAGS) $(APP_CXXFLAGS) $(APP_CFLAGS) -o $@ $<

#------------------------------------------------------------------------------
#                        TARGET RULES
#------------------------------------------------------------------------------

.PHONY : help
help :
	@$(ECHO) "Summary of Makefile targets"
	@$(ECHO) "  Build targets:"
	@$(ECHO) "    all (default)    - Application and all libraries (including BSP)"
	@$(ECHO) "    bsp              - Just the BSP"
	@$(ECHO) "    libs             - All libraries (including BSP)"
	@$(ECHO) "    flash            - All flash files"	
	@$(ECHO) "    mem_init_install - All memory initialization files"
	@$(ECHO) "  Clean targets:"
	@$(ECHO) "    clean_all        - Application and all libraries (including BSP)"
	@$(ECHO) "    clean            - Just the application"
	@$(ECHO) "    clean_bsp        - Just the BSP"
	@$(ECHO) "    clean_libs       - All libraries (including BSP)"
	@$(ECHO) "  Run targets:"
	@$(ECHO) "    download-elf     - Download and run your elf executable"
	@$(ECHO) "    program-flash    - Program flash contents to the board"

# Handy rule to skip making libraries and just make application.
.PHONY : app
app : $(ELF)

ifeq ($(CREATE_OBJDUMP), 1)
app : $(OBJDUMP_NAME)
endif

ifeq ($(CREATE_ELF_DERIVED_FILES),1)
app : elf_derived_files
endif

.PHONY: elf_derived_files
elf_derived_files: mem_init_install

# Handy rule for making just the BSP.
.PHONY : bsp
bsp :
	@$(ECHO) Info: Building $(BSP_ROOT_DIR)
	@$(MAKE) --no-print-directory -C $(BSP_ROOT_DIR)


# Make sure all makeable libraries (including the BSP) are up-to-date.
LIB_TARGETS := $(patsubst %,%-recurs-make-lib,$(MAKEABLE_LIBRARY_ROOT_DIRS))

.PHONY : libs
libs : $(LIB_TARGETS)

ifneq ($(strip $(LIB_TARGETS)),)
$(LIB_TARGETS): %-recurs-make-lib:
	@$(ECHO) Info: Building $*
	$(MAKE) --no-print-directory -C $*
endif

ifneq ($(strip $(APP_LDDEPS)),)
$(APP_LDDEPS): libs
	@true
endif

# Rules to force your project to rebuild or relink
# .force_relink file will cause any application that depends on this project to relink 
# .force_rebuild file will cause this project to rebuild object files
# .force_rebuild_all file will cause this project and any project that depends on this project to rebuild object files

FORCE_RELINK_DEP  := .force_relink
FORCE_REBUILD_DEP := .force_rebuild
FORCE_REBUILD_ALL_DEP := .force_rebuild_all
FORCE_REBUILD_DEP_LIST := $(FORCE_RELINK_DEP) $(FORCE_REBUILD_DEP) $(FORCE_REBUILD_ALL_DEP)

$(FORCE_REBUILD_DEP_LIST):

$(APP_OBJS): $(wildcard $(FORCE_REBUILD_DEP)) $(wildcard $(addsuffix /$(FORCE_REBUILD_ALL_DEP), . $(ALT_LIBRARY_DIRS)))

$(ELF): $(wildcard $(addsuffix /$(FORCE_RELINK_DEP), . $(ALT_LIBRARY_DIRS)))


# Clean just the application.
.PHONY : clean
ifeq ($(CREATE_ELF_DERIVED_FILES),1)
clean : clean_elf_derived_files
endif

clean :
	@$(RM) -r $(ELF) $(OBJDUMP_NAME) $(LINKER_MAP_NAME) $(OBJ_ROOT_DIR) $(FORCE_REBUILD_DEP_LIST)
	@$(ECHO) [$(APP_NAME) clean complete]

# Clean just the BSP.
.PHONY : clean_bsp
clean_bsp :
	@$(ECHO) Info: Cleaning $(BSP_ROOT_DIR)
	@$(MAKE) --no-print-directory -C $(BSP_ROOT_DIR) clean

# Clean all makeable libraries including the BSP.
LIB_CLEAN_TARGETS := $(patsubst %,%-recurs-make-clean-lib,$(MAKEABLE_LIBRARY_ROOT_DIRS))

.PHONY : clean_libs
clean_libs : $(LIB_CLEAN_TARGETS)

ifneq ($(strip $(LIB_CLEAN_TARGETS)),)
$(LIB_CLEAN_TARGETS): %-recurs-make-clean-lib:
	@$(ECHO) Info: Cleaning $*
	$(MAKE) --no-print-directory -C $* clean
endif

# Clean application and all makeable libraries including the BSP.
.PHONY : clean_all
clean_all : clean mem_init_clean clean_libs


# Include the dependency files unless the make goal is performing a clean
# of the application.
ifneq ($(firstword $(MAKECMDGOALS)),clean)
ifneq ($(firstword $(MAKECMDGOALS)),clean_all)
-include $(APP_DEPS)
endif
endif

.PHONY : download-elf
download-elf : $(ELF)
	@$(ECHO) Info: Downloading $(ELF)
	$(DOWNLOAD) --go --cpu_name=$(CPU_NAME) $(DOWNLOAD_CABLE_FLAG) $(SOPC_SYSID_FLAG) $(DOWNLOAD_JDI_FLAG) $(WRITE_GMON_OPTION) $(ELF)

# Delete the target of a rule if it has changed and its commands exit 
# with a nonzero exit status.
.DELETE_ON_ERROR:

# Rules for flash programming commands
PROGRAM_FLASH_SUFFIX := -program
PROGRAM_FLASH_TARGET := $(addsuffix $(PROGRAM_FLASH_SUFFIX), $(FLASH_FILES))

.PHONY : program-flash
program-flash : $(PROGRAM_FLASH_TARGET)

.PHONY : $(PROGRAM_FLASH_TARGET)
$(PROGRAM_FLASH_TARGET) : flash
	@$(ECHO) Info: Programming $(basename $@).flash
	@if [ -z "$($(basename $@)_EPCS_FLAGS)" ]; \
	then \
		$(ECHO) $(FLASHPROG) $(SOPC_SYSID_FLAG) --base=$($(basename $@)_START) $(basename $@).flash; \
		$(FLASHPROG) $(DOWNLOAD_CABLE_FLAG) $(SOPC_SYSID_FLAG) --base=$($(basename $@)_START) $(basename $@).flash; \
	else \
		$(ECHO) $(FLASHPROG) $(SOPC_SYSID_FLAG) --epcs --base=$($(basename $@)_START) $(basename $@).flash; \
		$(FLASHPROG) $(DOWNLOAD_CABLE_FLAG) $(SOPC_SYSID_FLAG) --epcs --base=$($(basename $@)_START) $(basename $@).flash; \
	fi

#------------------------------------------------------------------------------
#                         ELF TARGET RULE
#------------------------------------------------------------------------------
# Rule for constructing the executable elf file.
$(ELF) : $(APP_OBJS) $(LINKER_SCRIPT) $(APP_LDDEPS)
	@$(ECHO) Info: Linking $@
	$(LD) $(APP_LDFLAGS) $(APP_CFLAGS) -o $@ $(filter-out $(CRT0),$(APP_OBJS)) $(APP_LIBS) $(APP_BSP_DEP_LIBS)
ifneq ($(DISABLE_ELFPATCH),1)
	$(ELFPATCH) $@ $(ELF_PATCH_FLAG)
endif
ifneq ($(DISABLE_STACKREPORT),1)
	@$(STACKREPORT) $@
endif

$(OBJDUMP_NAME) : $(ELF)
	@$(ECHO) Info: Creating $@
	$(OBJDUMP) $(OBJDUMP_FLAGS) $< >$@

#------------------------------------------------------------------------------
#                         INFO TARGET RULE
#------------------------------------------------------------------------------
# Rule for printing the name of the elf file
.PHONY: print-elf-name
print-elf-name:
	@$(ECHO) $(ELF)

