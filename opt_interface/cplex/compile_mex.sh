#!/bin/tcsh

#set paths for libraries here
setenv CPLEX_LIB /fml/ag-raetsch/share/software/ilog/cplex90/lib/x86-64_RHEL3.0_3.2/static_pic/
setenv CPLEX_INC /fml/ag-raetsch/share/software/ilog/cplex90/include/ilcplex

echo CPLEX paths:
echo $CPLEX_LIB
echo $CPLEX_INC

#adjust the path to the mex binary here
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims cplex_init_quit.c
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims opt_set_param.c
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims lp_solve.c
mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread -largeArrayDims qp_solve.c

