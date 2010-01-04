PROJ=mosek

INCL = linux64x86/h
LIBS = linux64x86/bin

CXXFLAGS=-Wall -Wshadow -std=c++98 -ggdb -O3 -fPIC
CXXFLAGS2=-Wall -std=c++98 -ggdb -O3 -fPIC

MKOCT=~/octave/bin/mkoctfile
#MKOCT=/fml/ag-raetsch/share/software/octave-3.0.3/bin/mkoctfile

all:
	@ echo "Starting ${PROJ} creation..."
	@ echo "Compiling project..."
	$(MKOCT) ${PROJ}.cpp -o __${PROJ}_qp__.oct -I$(INCL) -L$(LIBS) -lmosek64 && echo "Success"

clean:
	rm *.o *.so *.oct
