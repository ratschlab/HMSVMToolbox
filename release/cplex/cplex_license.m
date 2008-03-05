function lpenv = cplex_license()
%  lpenv = cplex_license()

global lpenv ;
envstr = 'ILOG_LICENSE_FILE=access.ilm' ;
lpenv = cplex_init_quit(0, envstr) ;
