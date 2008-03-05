function ma = mov_avg(data, w)
% computes a moving average under a window of length w, 
% returned array will have size of data array - w

% written by Georg Zeller, MPI Tuebingen, Germany

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

