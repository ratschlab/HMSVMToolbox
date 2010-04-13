PROJ=mosek

INCL = ../mosek/6/tools/platform/linux64x86/h
LIBS = ../mosek/6/tools/platform/linux64x86/bin

CXXFLAGS=-Wall -Wshadow -std=c++98 -ggdb -O3 -fPIC
CXXFLAGS2=-Wall -std=c++98 -ggdb -O3 -fPIC

MKOCT=mkoctfile
#MKOCT=/usr/bin/mkoctfile3.0
#MKOCT=/fml/ag-raetsch/share/software/octave-3.2.3-64/bin/mkoctfile

all:
	@ echo "Starting ${PROJ} creation..."
	@ echo "Compiling project..."
	$(MKOCT) ${PROJ}.cpp -o __${PROJ}_qp__.oct -I$(INCL) -L$(LIBS) -lmosek64 && echo "Success"

clean:
	rm *.o *.so *.oct
