@echo off
SET src_file=main

ca65 -o main.o -t nes src/main.s -g
ld65 --target nes -o main.nes main.o --dbgfile main.dbg
