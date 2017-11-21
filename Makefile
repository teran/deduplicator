#!/usr/bin/make -f

LUAC := "luac5.1"

all: clean dependencies build

build:
	mkdir -p build temp/deduplicator.lrplugin/mac temp/deduplicator.lrplugin/win
	cp -v deduplicator.lrdevplugin/*.lua temp/deduplicator.lrplugin/
	sed 's~_BUILD_NUMBER_~'$(shell date +'%Y%m%d%H%M%S')'~' deduplicator.lrdevplugin/Info.lua > temp/deduplicator.lrplugin/Info.lua
	cp -v temp/imgsum/bin/imgsum-darwin-amd64 temp/deduplicator.lrplugin/mac/imgsum-amd64
	cp -v temp/imgsum/bin/imgsum-darwin-i386 temp/deduplicator.lrplugin/mac/imgsum-i386
	cp -v temp/imgsum/bin/imgsum-windows-amd64.exe temp/deduplicator.lrplugin/win/imgsum-amd64.exe
	cp -v temp/imgsum/bin/imgsum-windows-i386.exe temp/deduplicator.lrplugin/win/imgsum-i386.exe
	for file in `ls -1 temp/deduplicator.lrplugin/*.lua`; do $(LUAC) -s -o $$file $$file ; done
	cp -rv temp/deduplicator.lrplugin build/
	cd build && zip -r deduplicator.lrplugin.zip deduplicator.lrplugin

clean:
	rm -rvf build temp

dependencies:
	git clone https://github.com/teran/imgsum.git temp/imgsum
	cd temp/imgsum && make build-macos && make build-windows

sign:
	gpg --detach-sign --digest-algo SHA512 --no-tty --batch --output build/deduplicator.lrplugin.zip.sig build/deduplicator.lrplugin.zip

verify:
	gpg --verify build/deduplicator.lrplugin.zip.sig build/deduplicator.lrplugin.zip
