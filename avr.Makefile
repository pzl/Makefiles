DEVICE=attiny-2313

GNU = avr
COPS = -mmcu=$(DEVICE)

PROGRAMMER=avrdude
BOARD=stk500v2
PORT=/dev/ttyS1

POPS = -p $(DEVICE) -c $(BOARD) -P $(PORT)

TARGET=myfile


rom.hex: $(TARGET).out
	$(GNU)-objcopy -j .text -O ihex $(TARGET).out rom.hex

$(TARGET).out: $(TARGET).o
	$(GNU)-gcc $(COPS) -o $(TARGET).out -Wl,-Map,$(TARGET).map $(TARGET).o

$(TARGET).o: $(TARGET).c
	$(GNU)-gcc $(COPS) -Os -c $(TARGET).c


flash:
	$(PROGRAMMER) $(POPS) -U flash:w:rom.hex

clean:
	$(RM) *.o
	$(RM) *.out
	$(RM) *.map
	$(RM) *.hex

