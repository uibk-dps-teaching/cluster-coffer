# Makefile for AVR C++ projects
# From: https://gist.github.com/rynr/72734da4b8c7b962aa65

# ----- Update the settings of your project here -----

# Hardware
MCU     = atmega328p
AVRDUDE_PARAMS = -carduino -P/dev/ttyUSB0 -b115200 -D
FUSES = -U lfuse:w:0xff:m -U hfuse:w:0xda:m -U efuse:w:0xfd:m

# Parameters
PROJECT = $(lastword $(subst /, ,$(CURDIR)))
INC_BASE = $(shell find ArduinoCore/include -type d)
INCS = $(addprefix -I,$(INC_BASE))
LIBS =
DEFS = -DNDEBUG -DF_CPU=16000000L -DARDUINO=10809 -DARDUINO_AVR_NANO -DARDUINO_ARCH_AVR

# ----- These configurations are quite likely not to be changed -----

# Binaries
GCC     = avr-gcc
G++     = avr-g++
RM      = rm -f
AVRDUDE = avrdude
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE    = avr-size

# Files
EXT_C   = c
EXT_C++ = cpp
EXT_ASM = S

# ----- No changes should be necessary below this line -----

CTARGETS   = $(shell find . -type f -iname '*.$(EXT_C)')
C++TARGETS = $(shell find . -type f -iname '*.$(EXT_C++)')
ASMTARGETS = $(shell find . -type f -iname '*.$(EXT_ASM)')

OBJECTS = \
	$(patsubst %.$(EXT_C),%.o,$(CTARGETS)) \
	$(patsubst %.$(EXT_C++),%.o,$(C++TARGETS)) \
	$(patsubst %.$(EXT_ASM),%.o,$(ASMTARGETS))

# Linker and compiler flags
LDFLAGS = $(LIBS)
LDFLAGS += -Wl,-Map=$(PROJECT).map
LDFLAGS += -Wl,--gc-sections -mrelax

CFLAGS = $(INCS)
CFLAGS += $(DEFS)
CFLAGS += -Os
CFLAGS += -std=c11
CFLAGS += -funsigned-char -funsigned-bitfields -fshort-enums -ffunction-sections -fdata-sections -mrelax
CFLAGS += -Wall -Wextra -pedantic -Wstrict-prototypes
CFLAGS += -mmcu=$(MCU)

C++FLAGS = $(INCS)
C++FLAGS += $(DEFS)
C++FLAGS += -Os
C++FLAGS += -std=c++17
C++FLAGS += -funsigned-char -funsigned-bitfields -fshort-enums -ffunction-sections -fdata-sections -fno-threadsafe-statics -mrelax
C++FLAGS += -Wall -Wextra -pedantic
C++FLAGS += -mmcu=$(MCU)

ASMFLAGS = $(INCS)
ASMFLAGS += $(DEFS)
ASMFLAGS += -Os
ASMFLAGS += -funsigned-char -funsigned-bitfields -fshort-enums -ffunction-sections -fdata-sections -fno-threadsafe-statics -mrelax
ASMFLAGS += -Wall -Wextra -pedantic -Wstrict-prototypes
ASMFLAGS += -x assembler-with-cpp
ASMFLAGS += -mmcu=$(MCU)

all: $(PROJECT).elf $(OBJECTS) $(PROJECT).hex $(PROJECT).srec $(PROJECT).eeprom $(PROJECT).lss
	$(SIZE) -C --mcu=$(MCU) $(PROJECT).elf

%.elf: $(OBJECTS)
	$(GCC) $(CFLAGS) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.$(EXT_C)
	$(GCC) $(CFLAGS) -c $< -o $@

%.o: %.$(EXT_C++)
	$(G++) $(C++FLAGS) -c $< -o $@

%.o: %.$(EXT_ASM)
	$(G++) $(ASMFLAGS) -c $< -o $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

%.srec: %.elf
	$(OBJCOPY) -j .text -j .data -O srec $< $@

%.eeprom: %.elf
	$(OBJCOPY) -j .eeprom --change-section-lma .eeprom=0 -O ihex $< $@

%.lss: %.elf
	$(OBJDUMP) -h -S $< > $@

clean:
	$(RM) $(PROJECT).elf $(OBJECTS) $(PROJECT).hex $(PROJECT).srec $(PROJECT).eeprom $(PROJECT).lss $(PROJECT).map

flash: $(PROJECT).hex
	sudo $(AVRDUDE) $(AVRDUDE_PARAMS) -p $(MCU) -U flash:w:$<:i

flash-eeprom: $(PROJECT).eeprom
	sudo $(AVRDUDE) $(AVRDUDE_PARAMS) -p $(MCU) -U eeprom:w:$<:i

flash-fuses:
	sudo $(AVRDUDE) $(AVRDUDE_PARAMS) -p $(MCU) $(FUSES)

flash-erase:
	sudo $(AVRDUDE) $(AVRDUDE_PARAMS) -p $(MCU) -e

help:
	@echo "usage:"
	@echo "  make <target>"
	@echo ""
	@echo "targets:"
	@echo "  all           Builds everything"
	@echo "  clean         Remove any non-source files"
	@echo "  flash         Flashes firmware"
	@echo "  flash-eeprom  Flashes eeprom"
	@echo "  flash-fuses   Flashes fuses"
	@echo "  flash-erase   Erases entire chip including eeprom"
	@echo "  help          Shows this help"
	@echo "  config        Shows the current configuration"
	@echo "  show-mcu      Show list of all possible MCUs"

config:
	@echo "configuration:"
	@echo ""
	@echo "Binaries for:"
	@echo "  C compiler:   $(GCC)"
	@echo "  C++ compiler: $(G++)"
	@echo "  remove files  $(RM)"
	@echo "  Programmer:   $(AVRDUDE)"
	@echo "  Obj copier:   $(OBJCOPY)"
	@echo "  Obj dumper:   $(OBJDUMP)"
	@echo "  Size calc:    $(SIZE)"
	@echo ""
	@echo "Hardware settings:"
	@echo "  MCU:            $(MCU)"
	@echo "  Avrdude params: $(AVRDUDE_PARAMS)"
	@echo "  Fuses:          $(FUSES)"
	@echo ""
	@echo "Project settings:"
	@echo "  Project name:       $(PROJECT)"
	@echo "  Include dirs:       $(INCS)"
	@echo "  Library dirs:       $(LIBS)"
	@echo "  Preprocessor defs:  $(DEFS)"
	@echo "  C compiler flags:   $(CFLAGS)"
	@echo "  C++ compiler flags: $(C++FLAGS)"
	@echo "  ASM compiler flags: $(ASMFLAGS)"
	@echo "  Linker flags:       $(LDFLAGS)"
	@echo ""
	@echo "Defaults:"
	@echo "  C-files:   *.$(EXT_C)"
	@echo "  C++-files: *.$(EXT_C++)"
	@echo "  ASM-files: *.$(EXT_ASM)"

show-mcu:
	$(G++) --target-help
