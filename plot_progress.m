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
end

clf
hold on
v_acc = mean([progress.val_acc]);
tr_acc = mean([progress.trn_acc]);
r_obj = [progress.objective] ./ max([progress.objective]);
plot(r_obj, '.--k');
plot(tr_acc, '.-b');
plot(v_acc, '.-r');
plot(length(progress), r_obj(end), 'dk');
plot(length(progress), tr_acc(end), 'db');
plot(length(progress), v_acc(end), 'dr');

xlabel('iteration');
ylabel('accuracy / relative objective');
legend({'validation accuracy', 'training accuracy', ...
        'rel. objective value'}, 'Location', 'SouthEast');
grid on
axis([0 length(progress)+1 0 1]);
for i=5:5:length(progress),
  text(i, 0.83, sprintf('%.0f min', progress(i).el_time/60));
end
