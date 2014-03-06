GNU ?= arm-none-eabi

CPU=cortex-m3

TARGET=myfile
SRCS=main.c

COPS = -Wall -Werror -O2 -nostdlib -nostartfiles -ffreestanding
#COPS +=-g -mthumb -mcpu=$(CPU) -stc=c99 -pedantic
LOPS = -T memmap
#AOPS = --warn --fatal-warnings

OBJS=$(SRCS:.c=.o)
AOBJS=$(SRCS:.s=.o)


all: $(TARGET).hex $(TARGET).bin $(TARGET).elf




#bin and hex variants
$(TARGET).bin: $(TARGET).elf
	$(GNU)-objcopy $< -O binary $@
$(TARGET).hex: $(TARGET).elf
	$(GNU)-objcopy $< -O ihex $@


#link and create ELF
$(TARGET).elf: $(OBJS)
	$(GNU)-ld $< $(LOPS) -o $@
	#$(GNU)-objdump -D $(TARGET).elf > $(TARGET).list

#compile all asm sources
.s.o:
	$(GNU)-as -o $@ $<
#compile all c sources
.c.o:
	$(GNU)-gcc $(COPS) -c -o $@ $<


clean:
	$(RM) *.o
	$(RM) *.bin
	$(RM) *.hex
	$(RM) *.elf
	$(RM) *.list
	$(RM) *.img


.PHONY: all clean
