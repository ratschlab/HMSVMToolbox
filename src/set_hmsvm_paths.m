% Extends the matlab path to directories needed by the HMSVM toolbox.
%
% see train_hmsvm.m
%

error('please set paths in set_hmsvm_paths.m') % comment this line
                                               % out, when done

% setting paths for mosek/octave version 5
%addpath opt_interface/mosek
%addpath opt_interface/mosek/src.5

% setting paths for mosek/octave version 6
%addpath opt_interface/mosek
%addpath opt_interface/mosek/src.6

% setting paths for mosek/matlab
%addpath opt_interface/mosek/mosek/6/toolbox/r2007a


% setting paths for cplex/matlab
%addpath opt_interface/cplex


% setting paths for native LP/QP solver
%addpath opt_interface/native

