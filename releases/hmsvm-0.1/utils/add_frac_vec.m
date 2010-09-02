function vec = add_frac_vec(vec, value, limits)
% vec = add_frac_vec(vec, value, limits)

% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

%assert(~any(isnan(limits)));
%assert(~any(isinf(limits)));

idx = sum(limits<=value);
if idx==0,
  vec(1) = vec(1)+1;
elseif idx==length(limits),
  vec(end) = vec(end)+1;
else
  vec(idx+1) = vec(idx+1) + (value-limits(idx))/(limits(idx+1)-limits(idx));  
  vec(idx)   = vec(idx)   + (limits(idx+1)-value)/(limits(idx+1)-limits(idx));
end