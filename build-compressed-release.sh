#!/bin/bash

set -e

mkdir -p zig-out/bin

echo Old:
ls -l zig-out/bin
echo

rm -rf zig-out/bin

zig build -Drelease-small -Dcpu=x86_64
echo Before strip:
ls -l zig-out/bin
echo

 ./vendor-tools/super-strip/sstrip zig-out/bin/zig-micro-game

 lzma --format=lzma -9 --extreme --lzma1=preset=9,lc=1,lp=0,pb=0 --keep zig-out/bin/zig-micro-game

cat ./vendor-tools/vondehi/vondehi zig-out/bin/zig-micro-game.lzma > zig-out/bin/zig-micro-game-compressed
chmod u+x zig-out/bin/zig-micro-game-compressed

echo Final:
ls -l zig-out/bin

ls -l zig-out/bin | cut -d ' ' -f 5,10 | grep -v '^$' >size.txt

