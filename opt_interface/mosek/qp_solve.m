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

r = mskqpopt(Q, f, A, [], b, lb, ub);

% solution vector
res = r.sol.itr.xx;
% constraint solution vector
lambda = r.sol.itr.xc;

% error message / return status
if r.rmsg == 'No error occurred.',
  how = 'OK';
else
  how = r.rmsg;
end

% eof