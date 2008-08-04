function cplex_close(lpenv_)
%  cplex_close(lpenv)

global lpenv 

[lpenv,status]=cplex_init_quit(1,'',lpenv_) ;


