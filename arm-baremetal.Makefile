ARMGNU ?= arm-none-eabi
COPS = -Wall -Werror -O2 -nostdlib -nostartfiles -ffreestanding
AOPS = --warn --fatal-warnings

TARGET=out

all: $(TARGET).hex $(TARGET).bin $(TARGET).elf


clean:
	$(RM) *.o
	$(RM) *.bin
	$(RM) *.hex
	$(RM) *.elf
	$(RM) *.list
	$(RM) *.img


filename.o: filename.s
	$(ARMGNU)-as filename.s -o filename.o

cfilenam.o: cfilenam.c
	$(ARMGNU)-gcc $(COPS) -c cfilenam.c -o cfilenam.o

$(TARGET).elf: filenames.o
	$(ARMGNU)-ld filenames.o -T memmap -o $(TARGET).elf
	$(ARMGNU)-objdump -D $(TARGET).elf > $(TARGET).list

$(TARGET).bin: $(TARGET).elf
	$(ARMGNU)-objcopy $(TARGET).elf -O binary $(TARGET).bin

$(TARGET).hex: $(TARGET).elf
	$(ARMGNU).objcopy $(TARGET).elf -O ihex $(TARGET).hex



