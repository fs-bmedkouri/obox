ifeq ($(CIRCLEHOME),)
	CIRCLEHOME=../../.cache/circle
endif

OBJS = main.o kernel.o ../../.cache/game.o
EXTRACLEAN = *.o *.d *.img *.elf *.map *.lst

LIBS = $(CIRCLEHOME)/lib/libcircle.a \
	$(CIRCLEHOME)/lib/usb/libusb.a \
	$(CIRCLEHOME)/lib/sound/libsound.a \
	$(CIRCLEHOME)/lib/input/libinput.a \
	$(CIRCLEHOME)/lib/fs/libfs.a \
	$(CIRCLEHOME)/addon/fatfs/libfatfs.a \
	$(CIRCLEHOME)/addon/SDCard/libsdcard.a

include $(CIRCLEHOME)/Rules.mk

-include $(DEPS)
