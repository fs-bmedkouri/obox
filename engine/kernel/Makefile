ifeq ($(CIRCLEHOME),)
	CIRCLEHOME=../../.cache/circle
endif

OBJS = main.o kernel.o ../../.cache/game.o
EXTRACLEAN = *.o *.d *.img *.elf *.map *.lst

LIBS = $(CIRCLEHOME)/lib/libcircle.a

include $(CIRCLEHOME)/Rules.mk

-include $(DEPS)
