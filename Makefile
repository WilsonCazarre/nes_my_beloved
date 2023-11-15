# ifeq ($(OS), Windows_NT)
# 	RM=del
# else
# 	RM=rm
# endif

SRC = src
OBJECTS = main.o
ROM = main.nes

all: $(ROM)

clean:
	rm main.o
	rm main.nes

$(ROM): $(OBJECTS)
	cl65 --target nes -o $(ROM) $(OBJECTS)

%.o: $(SRC)/%.s
	ca65 -o $@ -t nes $<
