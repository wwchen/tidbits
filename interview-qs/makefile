CC=g++
CFLAGS=
CPP := $(wildcard *.cpp)
OBJ := $(patsubst %.cpp,%.out,$(CPP))

all: $(OBJ)

%.out: $(CPP)
	$(CXX) -o $@ $^

	
clean: 
	rm -f *.o *~ *.out core

.PHONY: all clean
