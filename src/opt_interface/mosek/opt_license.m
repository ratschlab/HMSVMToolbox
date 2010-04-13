function opt_env = opt_license(waitflag, license_no)

% opt_env = opt_license([waitflag], [license_no])
%
% Gets a Mosek license and returns an environmental pointer to this
% solver instance.
%
% waitflag -- optional parameter; currently ignored for Mosek interface
% license_no -- optional parameter to specify a certain license manager; 
%   currently ignored for Mosek interface
% returns 1 (there is no license manager for Mosek so far)
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008



% Comment this line out when done setting the paths
error('Please set the paths in ...opt_interface/mosek/opt_license.m. Refer ..../opt_license/mosek/README for details');

addpath /fml/ag-raetsch/home/pramod/hmsvm/src/opt_interface/mosek/mosek/6/toolbox/r2007a/;
addpath /fml/ag-raetsch/home/pramod/hmsvm/src/opt_interface/mosek/mosek/6/tools/platform/linux64x86/bin/;
addpath /fml/ag-raetsch/home/pramod/hmsvm/src/opt_interface/mosek/mosek_interface/;


opt_env = 0;
