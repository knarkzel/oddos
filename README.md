# oddos

```shell
git clone https://github.com/knarkzel/oddos
cd oddos
nix develop
zig build run
```

## Debug with gdb

Start `qemu` first, then do following:

```
zig build gdb
(gdb) target remote localhost:1234
```
