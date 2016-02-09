# Makefile for MonkeyC programs, on Garmin's Connect IQ devices
# 
# run `make` for standard debuggable .prg files, suitable for the simulator
# run `make release` for building final binaries for a device
# run `make export` for making exported .iq files, that I don't know what they do
#
# Change the variables below to suit your project
#

# Your app's name. Should match strings exactly, will control the .prg filename
NAME=ActivityTracking

# what device you are building for. Can be overridden on a per-command basis like: `DEVICE=fenix3 make`
DEVICE ?= square_watch

# Point this to wherever your SDK is installed
SDK = ~/dev/connectiq/connectiq-sdk-mac-1.2.4/bin #we use the compiler from here. Don't really have to
WIN_SDK = ~/dev/connectiq/connectiq-sdk-win-1.2.4/bin #monkeydo must be converted to unix line endings, and edited to point to shell.exe and run it under wine

# These should point to the directories containing your .mc files, .xml, and final output files respectively
SOURCE_DIR ?= source
RESOURCE_DIR ?= resources
BUILD_DIR ?= build
#build dir cannot be blank. Final .prg files MUST be generated into a directory, not at top-level. Bug in monkeyc

# ----------------------------------------------------------------
# Below should be generic enough to not need changing per-project
# ----------------------------------------------------------------


#setup to replace the space-separated resource files as colon-separated
null:=
SPACE:=$(null) $(null)

SRCS=$(wildcard $(SOURCE_DIR)/*.mc)
RSRC=$(subst $(SPACE),:,$(wildcard $(RESOURCE_DIR)/*.xml))

PRG= $(BUILD_DIR)/$(NAME).prg #needs to be in subdirectory. See note below
IQ = $(BUILD_DIR)/$(NAME).iq

CC = $(SDK)/monkeyc

CFLAGS =  -i $(SDK)/api.debug.xml
CFLAGS += -p $(SDK)/projectInfo.xml
CFLAGS += -m manifest.xml
CFLAGS += -w
CFLAGS += -z $(RSRC)
CFLAGS += -d $(DEVICE)

all: $(PRG)

debug: CFLAGS += -g
debug: $(PRG)

release: CFLAGS += -r
release: $(PRG)

export: CFLAGS += -e -r
export: $(IQ)


#oddest bug ever. If output file here is put in the top directory,
#we get a null pointer exception from the compiler. Changing this
#to output the PRG in a subdirectory fixes it all
$(PRG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^

$(IQ): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	$(RM) $(PRG) $(IQ) $(NAME).prg.debug.xml
	$(RM) -rf $(BUILD_DIR)


simulate: $(PRG)
	WINEPREFIX=~/dev/connectiq/.wine wine $(WIN_SDK)/simulator.exe &
	sleep 2
	WINEPREFIX=~/dev/connectiq/.wine $(WIN_SDK)/monkeydo $(PRG)

.PHONY: all debug release export clean simulate
