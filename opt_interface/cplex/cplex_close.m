function cplex_close(opt_env_)

% cplex_close(opt_env)
%
% Quits CPLEX, freeing the license specified by opt_env_.
%
% written by Gunnar Raetsch, MPI Tuebingen, Germany, 2008

global opt_env 

[opt_env, status] = cplex_init_quit(1, '', opt_env_);


