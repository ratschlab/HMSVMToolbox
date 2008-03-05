#/bin/bash

mex cplex_init_quit.c
mex lp_set_param.c
mex qp_solve.c
mex lp_solve.c
