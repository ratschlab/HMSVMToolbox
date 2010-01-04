#!/bin/bash

export CPLEX_LIB=/fml/ag-raetsch/share/software/ilog/cplex90/lib/x86-64_RHEL3.0_3.2/static_pic/
export CPLEX_INC=/fml/ag-raetsch/share/software/ilog/cplex90/include/ilcplex

if [ ! -d $CPLEX_LIB ];
then
	echo CPLEX library dir does not exist \(currently set to $CPLEX_LIB\)
	echo please edit compile_mex.sh
	exit -1
fi

if [ ! -d $CPLEX_INC ];
then
	echo CPLEX include dir does not exist \(currently set to $CPLEX_INC\)
	echo please edit compile_mex.sh
	exit -1
fi

mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims cplex_init_quit.c
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims opt_set_param.c
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims lp_solve.c
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims qp_solve.c

