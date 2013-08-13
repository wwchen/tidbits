CC=g++
CFLAGS=
CPPS := $(wildcard *.cpp)
OBJS := $(patsubst %.cpp,%.out,$(CPPS))

all: $(OBJS)

%.out: %.cpp
	$(CXX) -o $@ $^
	
clean: 
	rm -f *.o *~ *.out core

.PHONY: all clean
