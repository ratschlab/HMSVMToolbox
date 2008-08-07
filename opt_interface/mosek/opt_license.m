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


% TODO so far, no licesning system is used...
opt_env = 0;