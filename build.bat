@echo off
SET src_file=main

ca65 -o main.o -t nes src/main.s
cl65 --target nes -o main.nes main.o
start Mesen.exe main.nes