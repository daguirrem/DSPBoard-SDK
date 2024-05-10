# David A. Aguirre M. - daguirre.m@outlook.com
# BASED on Cortex-Builder MAKEFILE (https://github.com/7bnx/Cortex-Builder)
# NOTE:
# Tested on Windows 10/11

#MIT License
#Copyright (c) 2020 Semyon Ivanov - 2022-2023 David A. Aguirre M.

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:


#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

INCLUDEDEFINE =
INCLUDE_PATH =
LIBS =
LIBDIR =
LIB_SDK =

include user.mk

#Make
ifneq ($(XPACK),)
	ECHO = "${XPACK}/echo.exe"
	MKDIR = "${XPACK}/mkdir.exe"
	COPY = "${XPACK}/cp.exe"
	SH = "${XPACK}/sh.exe"
	POSTFIX = .exe
	ECHOPREFIX = -e
else
	ECHO = "echo"
	MKDIR = "mkdir"
	COPY = "cp"
	SH = "sh"
	POSTFIX =
endif

ifeq ($(PROGRAMMER),bmp)
	PROGRAMMER_COMMAND = $(BMP_COMMAND)
	PROGRAMMER_ARGS = -wV $(OUTPUT_PATH)/$(PRJ_NAME).bin -a $(FLASHSTART)
else
	PROGRAMMER_COMMAND = $(ST_COMMAND)
	PROGRAMMER_ARGS = -f interface/stlink.cfg -f target/stm32f4x.cfg \
		-c 'program $(OUTPUT_PATH)/$(PRJ_NAME).elf verify reset exit'
endif

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

# Necesary options
PRJ_NAME = $(TARGET)
FPU_HARDWARE = yes
HSE_VALUE = 8000000UL
FLASHSTART = 0x08000000
TOOLCHAIN =
TOOLCHAIN_VERSION =
CMSIS_PATH = 
LIB_PATH = build/lib/$(TARGET)

# MCU Defines
CORE = cortex-m4
INCLUDEDEFINE += \
	STM32F407xx \
	STM32F4xx \
	ARM_MATH_CM4 \
	HSE_VALUE=$(HSE_VALUE)

# Folders
BUILD_PATH = build/$(TARGET)
OUTPUT_PATH = output/$(TARGET)
INCLUDE_PATH += \
	./include \
	$(CMSIS_PATH)/Include \
	$(CMSIS_PATH)/Device/ST/STM32F4xx/Include \
	$(CMSIS_PATH)/DSP/Include \
	$(EXT_LIB_INCLUDE)

SOURCE_PATH = src
EXTRA_SOURCE_PATH = libs
EXTRA_SOURCE_PATH_LIST = $(wildcard $(EXTRA_SOURCE_PATH)/*/)

OBJECT_PATH = build/$(TARGET)/src

LIBS += $(foreach lib, $(LIB_SDK),-l$(lib))
LIBS_BUILDED = $(foreach lib, $(LIB_SDK),$(LIB_PATH)/lib$(lib).a)
# LIBS_INC_DIR = $(foreach lib, $(LIB_SDK),include/$(lib).h)

# Settings
CPPSTANDARD = gnu++17
CSTANDARD = gnu11

ifeq ($(TARGET),Debug)
	INCLUDEDEFINE += DEBUG
	DEBUG          = -ggdb3
	OPT_FLAG       = -Og
else
	INCLUDEDEFINE += _NDEBUG
	DEBUG          = -ggdb2
	OPT_FLAG       = $(OPTIMIZATION)
endif

# Compiler
PREFIX = $(TOOLCHAIN)/bin/arm-none-eabi-
CC = "$(PREFIX)gcc$(POSTFIX)"
CXX = "$(PREFIX)g++$(POSTFIX)"
AS = "$(PREFIX)gcc$(POSTFIX)"
CP = "$(PREFIX)objcopy$(POSTFIX)"
SZ = "$(PREFIX)size$(POSTFIX)"
OBJDUMP = "$(PREFIX)objdump$(POSTFIX)"
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

# MCU Flags
CPU = -mcpu=$(CORE)
FPU = -mfpu=fpv4-sp-d16
ifeq ($(FPU_HARDWARE),yes)
	FLOATABI = -mfloat-abi=hard
	CANDCPP_INCLUDES += -I__VFP_FP__=1 -U__SOFTFP__
else
	FLOATABI = -mfloat-abi=soft
	CANDCPP_INCLUDES += -U__SOFTFP__=1 -I__VFP_FP__
endif
MCU = $(CPU) -mthumb $(FPU) $(FLOATABI)

# Defines
ASM_DEFINES = 
CANDCPP_DEFINES = $(foreach definition, $(INCLUDEDEFINE),-D$(definition))

ASM_INCLUDES =
CANDCPP_INCLUDES += -I./system
CANDCPP_INCLUDES += $(foreach include, $(INCLUDE_PATH),-I"$(include)")
CANDCPP_INCLUDES  += $(foreach esrcp, $(EXTRA_SOURCE_PATH_LIST),-I"$(esrcp)/include")

ASM_SOURCE = $(wildcard ./system/startup_*.s)
C_SOURCE = $(wildcard ./system/system_*.c)
C_SOURCE += $(wildcard $(SOURCE_PATH)/*.c)
C_SOURCE += $(wildcard $(EXTRA_SOURCE_PATH)/*/src/*.c)

CPP_SOURCE = $(wildcard $(SOURCE_PATH)/*.cpp)
CPP_SOURCE += $(wildcard $(EXTRA_SOURCE_PATH)/*/src/*.cpp)

# Linker
LDSCRIPT = ld/linker.ld
LIBS += -lc -lm -lnosys -larm_cortexM4lf_math

LIBDIR += -L"$(LIB_PATH)"
LIBDIR += -L"$(CMSIS_PATH)/Lib/GCC"

LDFLAGS = $(MCU) -specs=nano.specs -specs=nosys.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS)\
-Wl,-Map=$(BUILD_PATH)/$(PRJ_NAME).map,--cref -Wl,--gc-sections

# Source flags
ASMFLAGS = $(MCU) $(ASM_DEFINES) $(ASM_INCLUDES) $(OPT_FLAG)\
-x assembler-with-cpp -Wall -Wextra -fdata-sections -ffunction-sections $(DEBUG)

CFLAGS = $(MCU) $(CANDCPP_DEFINES) $(CANDCPP_INCLUDES) $(OPT_FLAG) -std=$(CSTANDARD)\
-x c -Wall -Wextra -fdata-sections -ffunction-sections $(DEBUG)

CPPFLAGS = $(MCU) $(CANDCPP_DEFINES) $(CANDCPP_INCLUDES) $(OPT_FLAG) -std=$(CPPSTANDARD)\
-x c++ -Wall -Wextra -fdata-sections -ffunction-sections -fno-exceptions $(DEBUG)

# Obeject list
OBJECTS = $(addprefix $(BUILD_PATH)/,$(notdir $(C_SOURCE:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCE)))
OBJECTS += $(addprefix $(BUILD_PATH)/,$(notdir $(CPP_SOURCE:.cpp=.o)))
vpath %.cpp $(sort $(dir $(CPP_SOURCE)))
OBJECTS += $(addprefix $(BUILD_PATH)/,$(notdir $(ASM_SOURCE:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCE)))
DEPS := $(OBJECTS:.o=.d)
-include $(DEPS)

ASMOUTPUTFILE = $(OBJDUMP) -DSG -t -marm -w --start-address=$(FLASHSTART) --show-raw-insn \
--visualize-jumps --inlines $(OUTPUT_PATH)/$(PRJ_NAME).elf \
-Mforce-thumb -Mreg-names-std > $(OUTPUT_PATH)/$(PRJ_NAME).s

# Build
$(BUILD_PATH)/%.o: %.c Makefile | $(BUILD_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCompiling \033[1;34m["$<"] \033[0m"
	@$(CC) $(CFLAGS) -MMD -MP -Wa,-a,-ad,-alms=$(BUILD_PATH)/$(notdir $(<:.c=.lst)) -c "$<" -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(BUILD_PATH)/%.o: %.cpp Makefile | $(BUILD_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCompiling \033[1;34m["$<"] \033[0m"
	@$(CXX) $(CPPFLAGS) -MMD -MP -Wa,-a,-ad,-alms=$(BUILD_PATH)/$(notdir $(<:.cpp=.lst)) -c "$<" -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(BUILD_PATH)/%.o: %.s Makefile | $(BUILD_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCompiling \033[1;34m["$<"] \033[0m"
	@$(AS) -c $(ASMFLAGS) "$<" -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(OUTPUT_PATH)/$(PRJ_NAME).elf: $(OBJECTS) Makefile | $(OUTPUT_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\r\n\033[1;33mGenerating .elf file \033[0m"
	@$(CC) $(OBJECTS) $(LDFLAGS) -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"
	@${ECHO} $(ECHOPREFIX) -n "\033[1;33mGenerating .lst file \033[0m"
	@$(OBJDUMP) -h -S "$(OUTPUT_PATH)/$(PRJ_NAME).elf" > "$(OUTPUT_PATH)/$(PRJ_NAME).lst"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(OUTPUT_PATH)/%.hex: $(OUTPUT_PATH)/%.elf | $(OUTPUT_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[1;33mGenerating .hex file \033[0m"
	@$(HEX) $< "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(OUTPUT_PATH)/%.bin: $(OUTPUT_PATH)/%.elf | $(OUTPUT_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[1;33mGenerating .bin file \033[0m"
	@$(BIN) "$<" "$@"
	@$(ASMOUTPUTFILE)
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(BUILD_PATH):
	@${MKDIR} -p "$@"

$(OUTPUT_PATH):
	@${MKDIR} -p "$@"

$(LIB_PATH)/%.a: $(LIBS_INC_DIR) Makefile | $(BUILD_PATH)
	@${MAKE} -s -C '$(EXT_LIB_PATH)/$(patsubst $(LIB_PATH)/lib%.a,'%',$@)/lib' \
	export \
	"LIB_NAME=$(patsubst $(LIB_PATH)/lib%.a,%,$@)" \
	"EXPORT_PATH=$(subst ' ','\ ',$(mkfile_dir))" \
	"EXT_LIB_INCLUDE=$(EXT_LIB_INCLUDE)" \
	"FPU_HARDWARE=$(FPU_HARDWARE)" \
	"OPT_FLAG=$(OPT_FLAG)" \
	"CORE=$(CORE)" \
	"INCLUDEDEFINE=$(INCLUDEDEFINE)" \
	"CPPSTANDARD=$(CPPSTANDARD)" \
	"CSTANDARD=$(CSTANDARD)" \
	"CPU=$(CPU)" \
	"FPU=$(FPU)" \
	"MCU=$(MCU)" \
	"FLOATABI=$(FLOATABI)"

# include/%.h:
# 	@${MAKE} -s -C '$(EXT_LIB_PATH)/$(patsubst include/%.h,'%',$@)/lib' \
# 	incl_exp \
# 	"EXPORT_PATH=$(mkfile_dir)"

# include/%.hpp:
# 	@${MAKE} -s -C '$(EXT_LIB_PATH)/$(patsubst include/%.hpp,'%',$@)/lib' \
# 	incl_exp \
# 	"EXPORT_PATH=$(mkfile_dir)"

# Actions
.PHONY: build clean program version #incl_imp

version:
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[ALTELEC - HOTBET OF RESEARCH]\033[0m"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[DSP Board SDK] [make]\033[0m\r\n"
	@${ECHO} $(ECHOPREFIX) "\033[1;32mBuilding wtih:\033[0m"
	@$(CC) --version

build: version $(LIBS_BUILDED) $(OUTPUT_PATH)/$(PRJ_NAME).bin $(OUTPUT_PATH)/$(PRJ_NAME).hex
	@${ECHO} $(ECHOPREFIX) "\r\n\033[1;32mBuild done\033[0m\r\n"

clean:
	@${ECHO} $(ECHOPREFIX) -n "\033[1;31mCleaning $(PRJ_NAME) project "
	@rm -rf ./output/
	@rm -rf ./build/
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

program: build
	$(PROGRAMMER_COMMAND) $(PROGRAMMER_ARGS)

# incl_imp: $(LIBS_INC_DIR)
