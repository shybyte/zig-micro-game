mkdir -p zig-out/bin

echo Old:
ls -l zig-out/bin

rm -rf zig-out/bin

zig build -Drelease-small -Dcpu=x86_64

echo New:
ls -l zig-out/bin

