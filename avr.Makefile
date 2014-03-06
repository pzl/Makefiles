GNU = avr


DEVICE=attiny-2313 
PROGRAMMER=avrdude
BOARD=stk500v2
PORT=/dev/ttyS1


TARGET=myfile
SRCS = main.c


COPS = -mmcu=$(DEVICE) -g -Os -Wall -Wunused
#AOPS = -mmcu=$(DEVICE) -x assembler-with-cpp -Wa,-gstabs
LOPS = -mmcu=$(DEVICE) -Wl,-Map=$(TARGET).map
POPS = -p $(DEVICE) -c $(BOARD) -P $(PORT)

OBJS = $(SRCS:.c=.o)

all: $(TARGET).hex



#convert to hex for flashing
$(TARGET).hex: $(TARGET).elf
	$(GNU)-objcopy -j .text -O ihex $< $@
	#$(GNU)-objcopy -O ihex -R .eeprom $< $@

#linking and making an elf?
$(TARGET).elf: $(OBJS)
	$(GNU)-ld $(OBJS) $(LOPS) -o $@

#compile all the c sources
.c.o:
	$(GNU)-gcc $(COPS) -c -o $@ $<



#uploading the ROM
flash: $(TARGET).hex
	$(PROGRAMMER) $(POPS) -U flash:w:$<

verify: $(TARGET).hex
	$(PROGRAMMER) $(POPS) -U flash:v:$<

clean:
	$(RM) *.o
	$(RM) *.elf
	$(RM) *.map
	$(RM) *.hex

.PHONY: all flash verify clean
