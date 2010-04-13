#!/bin/tcsh

#set paths to CPLEX libraries here
setenv CPLEX_LIB /fml/ag-raetsch/share/software/ilog/cplex90/lib/x86-64_RHEL3.0_3.2/static_pic/
setenv CPLEX_INC /fml/ag-raetsch/share/software/ilog/cplex90/include/ilcplex

echo CPLEX paths:
echo $CPLEX_LIB
echo $CPLEX_INC

#ensure mkoctfile is in your $PATH or insert its full path here
mkoctfile --mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread cplex_init_quit.c
mkoctfile --mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread opt_set_param.c
mkoctfile --mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread lp_solve.c
mkoctfile --mex -I$CPLEX_INC -L$CPLEX_LIB -lcplex -lpthread qp_solve.c

