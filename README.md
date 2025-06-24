# obox
Odin baremetal RasberryPi playground for games

Build under Linux or Debian/Ubuntu WSL.
Install build-essential, unzip, xz-utils and just run the Makefile.
(You do not need any ARM toolchains or Odin installed.)

By default the 'sample' game is built for a RaspberryPi 3.
You can control this with the 'GAME' and 'RPI' environment variable when calling make.

Put the resulting content in builds/sdcard on to a FAT32 formated SDCard.
