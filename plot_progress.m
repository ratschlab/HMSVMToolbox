function plot_progress(progress, fh)

% plot_progress(progress, [fh])
%
% Plots the training progress.
%
% progress -- a struct with field recording the training progress 
%   (see train_hmsvm.m)
% fh -- an optional parameter specifying a fugure handle to plot into
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008

if exist('fh', 'var'),
  figure(fh);
  clf
else
  figure;
end

hold on
lg = {};
if isfield(progress, 'objective'),
  r_obj = [progress.objective] ./ max([progress.objective]);
  plot(r_obj, '.--k');
  lg{end+1} = 'rel. objective value';
end

tr_acc = mean([progress.trn_acc]);
plot(tr_acc, '.-b');
lg{end+1} = 'training accuracy';

if isfield(progress, 'val_acc'),
  v_acc = mean([progress.val_acc]);
  plot(v_acc, '.-r');
  lg{end+1} = 'validation accuracy';
end

xlabel('iteration');
if isfield(progress, 'objective'),
  plot(length(progress), r_obj(end), 'dk');
  ylabel('accuracy / relative objective');
else
  ylabel('accuracy');
end
plot(length(progress), tr_acc(end), 'db');
if isfield(progress, 'val_acc'),
  plot(length(progress), v_acc(end), 'dr');
end

legend(lg, 'Location', 'NorthWest');
grid on
axis([0 length(progress)+1 0 1]);
if isfield(progress, 'el_time'),
  for i=5:5:length(progress),
    text(i, 0.05, sprintf('%.0f min', progress(i).el_time/60));
  end
end

% eof