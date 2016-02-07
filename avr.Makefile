GNU = avr

DEVICE=attiny85
PROGRAMMER=avrdude
BOARD=stk500v2
PORT=/dev/ttyS2

TARGET=bin
SRCS = main.c


COPS = -mmcu=$(DEVICE) -g -Os -Wall -Wunused
#AOPS = -mmcu=$(DEVICE) -x assembler-with-cpp -Wa,-gstabs
LOPS = -mmcu=$(DEVICE) -Wl,-Map=$(TARGET).map
POPS = -p $(DEVICE) -c $(BOARD) -P $(PORT)

OBJS = $(SRCS:.c=.o)

all: $(TARGET).hex



#convert to hex for flashing
$(TARGET).hex: $(TARGET).elf
	$(GNU)-objcopy -j .text -j .data -O ihex $< $@
	#$(GNU)-objcopy -O ihex -R .eeprom $< $@

#linking and making an elf?
$(TARGET).elf: $(OBJS)
	$(GNU)-gcc $(OBJS) $(LOPS) -o $@
	#$(GNU)-ld $(OBJS) $(LOPS) -o $@

#compile all the c sources
.c.o:
	$(GNU)-gcc $(COPS) -c -o $@ $<



#uploading the ROM
flash: $(TARGET).hex
	$(PROGRAMMER) $(POPS) -U flash:w:$<

verify: $(TARGET).hex
	$(PROGRAMMER) $(POPS) -U flash:v:$<

size: $(TARGET).elf
	$(GNU)-size --mcu=$(DEVICE) -C $<

clean:
	$(RM) *.o
	$(RM) *.elf
	$(RM) *.map
	$(RM) *.hex

.PHONY: all flash verify clean size
