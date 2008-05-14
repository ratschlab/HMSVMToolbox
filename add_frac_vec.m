function vec = add_frac_vec(vec, value, limits)

% vec = add_frac_vec(vec, value, limits)
%
% Adds weights w1 and w2 (both in [0, 1]) to the i-th and (i+1)-th
% entries of vec such that w1 + w2 = 1, limits(i) = max {limits <= value}
% and limits(i+1) = min {limits > value}. w1 and w1 are then calibrated
% by linear interpolation if the distance between the i-th limit and
% value or value and th (i+1)-th limit, respectively.
%
% Written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany, 2008

%assert(~any(isnan(limits)));
%assert(~any(isinf(limits)));

%assert(all(size(limits) == size(vec)));
%assert(isscalar(value));

idx = sum(limits<=value);
if idx==0,
  vec(1) = vec(1)+1;
elseif idx==length(limits),
  vec(end) = vec(end)+1;
else
  vec(idx+1) = vec(idx+1) + (value-limits(idx))/(limits(idx+1)-limits(idx));  
  vec(idx)   = vec(idx)   + (limits(idx+1)-value)/(limits(idx+1)-limits(idx));
end