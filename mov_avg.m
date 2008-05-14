function ma = mov_avg(data, w)

% ma = mov_avg(data, w)
%
% Computes a moving average in windows of length w.
%
% returns an array of the length of data - w
%
% Written by Georg Zeller, MPI Tuebingen, Germany, 2007-2008

if length(data) < w
  ma = [];
else
  c1 = cumsum(data);
  c2 = c1(w:end);
  c1 = [0 c1(1:end-w)];
  ma = (c2-c1)./w;
%  assert(round(10000*ma(1))==round(10000*mean(data(1:w))));
%  assert(round(10000*ma(end))==round(10000*mean(data(end-w+1:end))))
end

