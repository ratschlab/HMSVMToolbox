function [res, lambda, how] = qp_solve(opt_env, Q, f, A, b, lb, ub, neq, display, method);

% split constraint matrix into equality and inequality constraints
% the first 1:neq constraints are interpreted as equality constraints,
% the remainder as inequality constraints (of the form A*x <= b).

B = A(1:neq,:); %equality constraints
c = b(1:neq); %equality constraints
A(1:neq,:) = []; %inequality constraints
b(1:neq) = []; %inequality constraints


% Explanation:
%
%  x0   - the initial solution
%  P    - the quadratic term of the objective
%  q    - the linear part of the objective
%
%  A    - the matrix of the equality constraints
%  b    - rhs of the equality constraints
%
% lb    - lower bound on solution x ( lp <= x )
% ub    - upper bound on solution x ( x <= ub )
%
% A_lb  - lower bound for inequality constraints
% A_in  - Matrix representing inequality constraints
% A_ub  - upper bound for inequality constraints
dbstop
printf('Starting qp_solve using octave-inbuilt optimizer\n');
[x,obj,INFO,lambda] =  qp([], Q, f, B, c, lb, ub, b*0, A, b);

% solution vector
%keyboard
res = x;
% % error message / return status
if INFO < 6
  how = 'OK';
else
  how = INFO;
end
% eof
