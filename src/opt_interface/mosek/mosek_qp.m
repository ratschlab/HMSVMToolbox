function [res,obj] = mosek_qp(x0, P, q, A, b, lb, ub, A_lb, A_in, A_ub)
 [res,obj] = __mosek_qp__ (x0, P, q, A, b, lb, ub, A_lb, A_in, A_ub);


