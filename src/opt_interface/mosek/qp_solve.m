function [res, lambda, how] = qp_solve(opt_env, Q, f, A, b, lb, ub, neq, display, method);

% split constraint matrix into equality and inequality constraints
% the first 1:neq constraints are interpreted as equality constraints,
% the remainder as inequality constraints (of the form A*x <= b).
B = A(1:neq,:);
c = b(1:neq);
A(1:neq,:) = [];
b(1:neq) = [];

% method is ignored
% Mosek will always use interior point method

% TODO use the 'display' parameter to adjust the amount of output
%r = mskqpopt(Q, f, A, [], b, lb, ub, [], sprintf('echo(%i)', display));

matlab_check = ver('MATLAB');
octave_check = ver('Octave');

if (sum(size(matlab_check)) > 0),
   r = mskqpopt(Q, f, A, [], b, lb, ub);
   res = r.sol.itr.xx;
   lambda = r.sol.itr.xc;
   how = 'OK';
elseif (sum(size(octave_check)) > 0),
   [res,obj] = mosek_qp ([],Q,f,B,c,lb,ub,-1000+abs(b),A,b);
   how = 'OK';
   lambda = 0;
else
   error('Software supported only on MATLAB and Octave');
end

% solution vector
% constraint solution vector

% error message / return status
%if r.rmsg == 'No error occurred.',
%else
%  how = r.rmsg;
%end

% eof
