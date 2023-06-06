
default: test

testbin: test.c
	cat `which env` > "$@"
#	$(CC) -O3 -s -o "$@" "$<" #-static -nostdlib -nostartfiles

%.gz: %
	< "$<" gzip -cnk9 > "$@"
%.lzma: %
	< "$<" lzma --format=lzma -9 --extreme --lzma1=preset=9,lc=1,lp=0,pb=0 --keep --stdout > "$@"

vondehi: vondehi.asm
	nasm -fbin -DNO_CHEATING -DWANT_ARGV -o"$@" "$<"
	chmod +x "$@"

test: vondehi testbin.lzma
	-cat $^ > test && chmod +x test && strace -f ./test foo bar
	wc -c "$<"

.PHONY: default test

