@echo off
SET src_file=main

ca65 -o %src_file%.o -t nes src/%src_file%.s
cl65 --target nes -o %src_file%.nes main.o
start Mesen.exe %src_file%.nes