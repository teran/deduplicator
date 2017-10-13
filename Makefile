#!/usr/bin/make -f

LUAC := "luac5.1"

all: clean dependencies build

build:
	mkdir -p build temp/deduplicator.lrplugin/mac temp/deduplicator.lrplugin/win
	cp -v deduplicator.lrdevplugin/*.lua temp/deduplicator.lrplugin/
	cp -v temp/imgsum/bin/imgsum-darwin-amd64 temp/deduplicator.lrplugin/mac/imgsum
	cp -v temp/imgsum/bin/imgsum-windows-amd64.exe temp/deduplicator.lrplugin/win/imgsum.exe
	$(LUAC) -s -o temp/deduplicator.lrplugin/Info.lua temp/deduplicator.lrplugin/Info.lua
	$(LUAC) -s -o temp/deduplicator.lrplugin/FindDuplicates.lua temp/deduplicator.lrplugin/FindDuplicates.lua
	$(LUAC) -s -o temp/deduplicator.lrplugin/JSON.lua temp/deduplicator.lrplugin/JSON.lua
	cp -rv temp/deduplicator.lrplugin build/

clean:
	rm -rvf build temp

dependencies:
	git clone https://github.com/teran/imgsum.git temp/imgsum
	cd temp/imgsum && make build-macos && make build-windows
