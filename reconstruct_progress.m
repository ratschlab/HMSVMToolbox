function progress = reconstruct_progress(dr)

% progress = reconstruct_progress([dr])
%
% Reconstructs a progress struct reflecting the iterative training
% process by collecting progress structs that were written in every
% iteration
%
% dr -- optional argument spcifying a directory where progress has been
%   saved to; if not given, the current directory is searched 
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008-2009

VERBOSE = 1;
MAX_ITER = 500;

if ~exist('dr', 'var'),
  dr = pwd;
end

last_found = 0;
for i=1:MAX_ITER,
  fn = sprintf('%s/progress_iter%i.mat', dr, i);
  if fexist(fn),
    tmp = load(fn, 'progress');
    progress(i).objective = tmp.progress(end).objective;
    progress(i).el_time   = tmp.progress(end).el_time;
    progress(i).trn_acc   = tmp.progress(end).trn_acc;
    progress(i).val_acc   = tmp.progress(end).val_acc;
    last_found = i;
  else
    progress(i).objective = nan;
    progress(i).el_time   = nan;
    progress(i).trn_acc   = nan;
    progress(i).val_acc   = nan;
  end
end
progress = progress(1:last_found);

if VERBOSE,
  plot_progress(progress);
end