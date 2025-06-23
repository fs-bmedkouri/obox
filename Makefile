ODIN_VERSION := 2025-06
CIRCLE_VERSION := 49.0.1

MKPATH = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
CIRCLEHOME = "$(MKPATH)"/.cache/circle
TOOLPATH = "$(PATH)":"$(MKPATH)"/.cache/toolchain/bin

all: kernel

.cache/odin:
	mkdir -p .cache
	rm -rf .cache/odin
	curl -L -o .cache/odin.zip https://github.com/odin-lang/Odin/releases/download/dev-$(ODIN_VERSION)/odin-linux-amd64-dev-$(ODIN_VERSION).zip
	cd .cache && mkdir -p odin && unzip -o odin.zip && tar -xf dist.tar.gz -C ./odin --strip-components=1

.cache/toolchain:
	mkdir -p .cache
	rm -rf .cache/toolchain
	curl -L -o .cache/toolchain.tar.xz https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-elf.tar.xz
	cd .cache && mkdir -p toolchain && tar -xf toolchain.tar.xz -C ./toolchain --strip-components=1

.cache/circle:
	mkdir -p .cache
	rm -rf .cache/circle
	curl -L -o .cache/circle.tar.gz https://github.com/rsta2/circle/archive/refs/tags/Step$(CIRCLE_VERSION).tar.gz
	cd .cache && mkdir -p circle && tar -xf circle.tar.gz -C ./circle --strip-components=1

.cache/circle/Config.mk: .cache/circle .cache/toolchain
	cd .cache/circle && PATH=$(TOOLPATH) CIRCLEHOME=$(CIRCLEHOME) ./configure -r 3 -p aarch64-none-elf-
	
build/sdcard: .cache/circle/Config.mk
	PATH=$(TOOLPATH) CIRCLEHOME=$(CIRCLEHOME) make -C $(CIRCLEHOME)/boot
	rm -rf build/sdcard
	mkdir -p build/sdcard
	cp $(CIRCLEHOME)/boot/*.dtb build/sdcard
	cp $(CIRCLEHOME)/boot/*.dat build/sdcard
	cp $(CIRCLEHOME)/boot/*.bin build/sdcard
	cp $(CIRCLEHOME)/boot/*.elf build/sdcard
	cp $(CIRCLEHOME)/boot/config64.txt build/sdcard/config.txt

circle_pi3: .cache/circle/Config.mk
	cd .cache/circle && PATH=$(TOOLPATH) CIRCLEHOME=$(CIRCLEHOME) ./makeall

game: .cache/odin
	./.cache/odin/odin build game -out:.cache/game.o -build-mode:object -target:freestanding_arm64 -o:speed -collection:engine=engine

kernel: build/sdcard circle_pi3 game
	PATH=$(TOOLPATH) make -C engine/kernel
	cp engine/kernel/kernel8.img build/sdcard

clean:
	-$(MAKE) -C engine/kernel clean
	rm -rf .cache build

.PHONY: clean game kernel
