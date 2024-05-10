# David A. Aguirre M. - daguirre.m@outlook.com
# BASED on Cortex-Builder MAKEFILE (https://github.com/7bnx/Cortex-Builder)
# NOTE:
# Only Tested on Windows 10/11; BUILD A STATIC LIB

#MIT License
#Copyright (c) 2020 Semyon Ivanov - 2022 David A. Aguirre M.

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

# Necesary options
PRJ_NAME = #ASSIGN LIB NAME
LIB_NAME = #ASSIGN LIB NAME
FPU_HARDWARE = yes
TOOLCHAIN =
TOOLCHAIN_VERSION =
OPT_FLAG =
EXT_LIB_INCLUDE =
# MCU Defines
CORE = cortex-m4
INCLUDEDEFINE = \
	STM32F407xx \
	STM32F4xx \
	HSE_VALUE=$(HSE_VALUE)

# Folders
BUILD_PATH = build/$(TARGET)
OUTPUT_PATH = output/$(TARGET)
INCLUDE_PATH = \
	$(EXT_LIB_INCLUDE) \
	$(EXPORT_PATH)/include \
	$(CMSIS_PATH)/Include \
	$(CMSIS_PATH)/DSP/Include \
	$(CMSIS_PATH)/Device/ST/STM32F4xx/Include \

SOURCE_PATH = \
	src

OBJECT_PATH = build/$(TARGET)/src

#Settings
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
AR = "$(PREFIX)ar$(POSTFIX)"
OBJDUMP = "$(PREFIX)objdump$(POSTFIX)"

# Defines
ASM_DEFINES =
CANDCPP_DEFINES = $(foreach definition, $(INCLUDEDEFINE),-D$(definition))

# MCU Flags
CPU = -mcpu=$(CORE)
FPU = -mfpu=fpv4-sp-d16
ifeq ($(FPU_HARDWARE),yes)
	FLOATABI = -mfloat-abi=hard
	CANDCPP_DEFINES += -D__VFP_FP__=1 -U__SOFTFP__
else
	FLOATABI = -mfloat-abi=soft
	CANDCPP_DEFINES += -D__SOFTFP__=1 -U__VFP_FP__
endif
MCU = $(CPU) -mthumb $(FPU) $(FLOATABI)

ASM_INCLUDES =
CANDCPP_INCLUDES += $(foreach include, $(INCLUDE_PATH),-I"$(include)")

C_SOURCE += $(wildcard $(SOURCE_PATH)/*.c)
CPP_SOURCE = $(wildcard $(SOURCE_PATH)/*.cpp)

# Source flags
ASMFLAGS = $(MCU) $(ASM_DEFINES) $(ASM_INCLUDES) $(OPT_FLAG)\
-x assembler-with-cpp -Wall -fdata-sections -ffunction-sections -specs="nosys.specs"
CFLAGS = $(MCU) $(CANDCPP_DEFINES) $(CANDCPP_INCLUDES) $(OPT_FLAG) -std=$(CSTANDARD)\
-x c -Wall -fdata-sections -ffunction-sections $(DEBUG) -specs="nosys.specs"
CPPFLAGS = $(MCU) $(CANDCPP_DEFINES) $(CANDCPP_INCLUDES) $(OPT_FLAG) -std=$(CPPSTANDARD)\
-x c++ -Wall -fdata-sections -ffunction-sections -fno-exceptions $(DEBUG) -specs="nosys.specs"

# Obeject list
OBJECTS = $(addprefix $(BUILD_PATH)/,$(notdir $(C_SOURCE:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCE)))
OBJECTS += $(addprefix $(BUILD_PATH)/,$(notdir $(CPP_SOURCE:.cpp=.o)))
vpath %.cpp $(sort $(dir $(CPP_SOURCE)))
OBJECTS += $(addprefix $(BUILD_PATH)/,$(notdir $(ASM_SOURCE:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCE)))
DEPS := $(OBJECTS:.o=.d)
-include $(DEPS)

OUTPUT_FILES = $(addsuffix .a, $(addprefix lib,$(LIB_NAME)))

# Build
$(BUILD_PATH)/%.o: %.c Makefile | $(BUILD_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCompiling \033[0;34m["$<"] \033[0m"
	@$(CC) $(CFLAGS) -MMD -MP -Wa,-a,-ad,-alms=$(BUILD_PATH)/$(notdir $(<:.c=.lst)) -c "$<" -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(BUILD_PATH)/%.o: %.cpp Makefile | $(BUILD_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCompiling \033[0;34m["$<"] \033[0m"
	@$(CXX) $(CPPFLAGS) -MMD -MP -Wa,-a,-ad,-alms=$(BUILD_PATH)/$(notdir $(<:.cpp=.lst)) -c "$<" -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(BUILD_PATH)/%.o: %.s Makefile | $(BUILD_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCompiling \033[0;34m["$<"] \033[0m"
	@$(AS) -c $(ASMFLAGS) "$<" -o "$@"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(OUTPUT_PATH)/lib%.a: $(OBJECTS) Makefile | $(OUTPUT_PATH)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mBuilding \033[0;34m["$@"] \033[0m"
	@${AR} -c $(LDFLAGS) -r "$@" $(OBJECTS)
	@$(OBJDUMP) -h -S $@ > "$(OUTPUT_PATH)/lib${LIB_NAME}.lst"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"

$(BUILD_PATH):
	@${MKDIR} -p "$@"

$(OUTPUT_PATH):
	@${MKDIR} -p "$@"

# Actions
.PHONY: build clean export incl_exp version

version:
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[$(LIB_NAME)]\033[0m"
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Generating static library] ---------------- \033[0m\r\n"
build: version $(OUTPUT_PATH)/$(OUTPUT_FILES)
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mExporting library\033[0m"
	@${COPY} -rf ./output/. '$(EXPORT_PATH)/build/lib'
	@${ECHO} $(ECHOPREFIX) "\033[1;32m [Done]\033[0m"

clean:
	@${ECHO} $(ECHOPREFIX) -n "\033[0;33mCleaning library dir\033[0m"
	@rm -rf ./output/
	@rm -rf ./build/
	@${ECHO} $(ECHOPREFIX) "\033[1;32m [Done]\033[0m"

export: build clean
	@${ECHO} $(ECHOPREFIX) "\r\n\033[1;32m[Done] ------------------------------------- \033[0m\r\n"

incl_exp:
	@${ECHO} $(ECHOPREFIX) -n "\033[1;34m[$(LIB_NAME)] \033[1;33mExporting includes \033[0m"
	@${COPY} -rf ./include/. '$(EXPORT_PATH)/include'
	@${ECHO} $(ECHOPREFIX) "\033[1;32m[Done]\033[0m"
