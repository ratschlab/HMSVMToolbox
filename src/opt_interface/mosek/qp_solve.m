
function [res, lambda, how] = qp_solve(opt_env, Q, f, A, b, lb, ub, neq, display, method);

% split constraint matrix into equality and inequality constraints
% the first 1:neq constraints are interpreted as equality constraints,
% the remainder as inequality constraints (of the form A*x <= b).

B = A(1:neq,:); %equality constraints
c = b(1:neq); %equality constraints
A(1:neq,:) = []; %inequality constraints
b(1:neq) = []; %inequality constraints



% __mosek_qp_ (x0, P, q, A, b, lb, ub, A_lb, A_in, A_ub)
% 
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
%
%
% The MOSEK representation is equivalent
%

% method is ignored
% Mosek will always use interior point method
[res, obj] =  __mosek_qp__ ([], Q, f, B, c, lb, ub, -10000000*abs(b), A, b);
obj
lambda = 0;
% 
% % error message / return status
%if INFO == 0,
how = 'OK';
%else
%  how = INFO;
%end

% eof
