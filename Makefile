ifeq ($(OS), Windows_NT)
	RM=del
else
	RM=rm
endif

rootdir = $(realpath .)


SRC = src
OBJECTS = main.o
ROM = main.nes

.PHONY: startrom

startrom: build $(ROM)
	start "$(rootdir)/Mesen.exe" $(ROM)

build: $(ROM)

all:
	build
	startrom

clean:
	rm main.o
	rm main.nes

$(ROM): $(OBJECTS) lib
	cl65 --target nes -o $(ROM) $(OBJECTS)

%.o: $(SRC)/%.s lib
	ca65 -o $@ -t nes $<

lib: ;