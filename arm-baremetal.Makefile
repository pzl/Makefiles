GNU ?= arm-none-eabi


#cortex-m0
#cortex-m3
#cortex-m4
CPU=

TARGET=myproject
VERSION=0.0.1



SRCDIR=src
OBJDIR=build


CC ?= gcc

CFLAGS += -Wall -Wextra -Werror -O2
CFLAGS += -nostdlib -nostartfiles -ffreestanding -fno-common
CFLAGS += -Wfloat-equal -Wundef -Wshadow -Wpointer-arith -Wcast-align
CFLAGS += -Wstrict-prototypes -Wwrite-strings -Wpadded
CFLAGS += -mthumb -mcpu=$(CPU)
CFLAGS += -DVERSION=\"$(VERSION)\"
SFLAGS = -std=c89 -pedantic
LFLAGS = -Map=$(TARGET).map -T$(TARGET).ld
AFLAGS = -mcpu=$(CPU)
#AOPS = --warn --fatal-warnings
INCLUDES= -I.





SRCS_C=$(wildcard $(SRCDIR)/*.c)
SRCS_S=$(wildcard $(SRCDIR)/*.s)
OBJS_C=$(SRCS:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
OBJS_S=$(SRCS:$(SRCDIR)/%.s=$(OBJDIR)/%.o)


all: $(TARGET).hex $(TARGET).bin $(TARGET).elf


#recompile when makefile changes
$(OBJS_C): Makefile

#create build dir if it doesn't exist
dummy := $(shell test -d $(OBJDIR) || mkdir -p $(OBJDIR))





#bin and hex variants
$(TARGET).bin: $(TARGET).elf
	$(GNU)-objcopy $< -O binary -j .text -j .data $@
$(TARGET).hex: $(TARGET).elf
	$(GNU)-objcopy $< -O ihex -R .stack $@


#link and create ELF
$(TARGET).elf: $(OBJS_C) $(OBJS_S)
	$(GNU)-ld $< $(LFLAGS) $(SFLAGS) $(CFLAGS) -o $@
	#$(GNU)-objdump -D $(TARGET).elf > $(TARGET).list

#compile all asm sources
.s.o:
	$(GNU)-as $(AFLAGS) -o $@ $<
#compile all c sources
.c.o:
	$(GNU)-$(CC) $(CFLAGS) $(SFLAGS) $(INCLUDES) -c -o $@ $<


clean:
	$(RM) $(OBJDIR)/$(OBJ_C)
	$(RM) $(OBJDIR)/$(OBJ_S)
	$(RM) $(TARGET).bin $(TARGET).hex $(TARGET).elf
	#$(RM) *.list
	#$(RM) *.img


.PHONY: all clean dummy flash
