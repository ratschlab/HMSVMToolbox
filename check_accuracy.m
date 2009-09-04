function check_accuracy(ARGS)

% check_accuracy(ARGS)
%
%
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008-2009

for i=1:length(ARGS.PAR.include_paths),
  addpath(ARGS.PAR.include_paths{i});
end
  
progress = ARGS.progress;
iter = ARGS.iter;

t_start_ac = clock();
for j=1:length(ARGS.train_exm_ids),
  trn_idx = find(ARGS.exm_id_intervals(:,1)==ARGS.train_exm_ids(j));
  trn_idx = ARGS.exm_id_intervals(trn_idx,2):ARGS.exm_id_intervals(trn_idx,3);
  trn_obs_seq = ARGS.signal(:,trn_idx);
  trn_pred_path = decode_Viterbi(trn_obs_seq, ARGS.transition_scores, ...
                                 ARGS.score_plifs, ARGS.PAR);
  trn_true_label_seq = ARGS.label(trn_idx);
  trn_pred_label_seq = trn_pred_path.label_seq;
  trn_acc(j) = mean(trn_true_label_seq(1,:)==trn_pred_label_seq(1,:));
  
  if ARGS.PAR.verbose>=3 && j<=25,
    view_label_seqs(gcf, trn_obs_seq, trn_true_label_seq, trn_pred_label_seq);
    title(gca, ['Training example ' num2str(ARGS.train_exm_ids(j))]);
    fprintf('Training example %i\n', ARGS.train_exm_ids(j));
    fprintf('  Example accuracy: %3.2f%%\n', 100*trn_acc(j));
    pause
  end
end
fprintf(['\nIteration %i:\n' ...
         '  LSL training accuracy:              %2.2f%%\n'], ...
        iter, 100*mean(trn_acc));
progress(iter).trn_acc = trn_acc';

%%% check prediction accuracy on holdout examples
if ~isempty(ARGS.holdout_exm_ids),
  for j=1:length(ARGS.holdout_exm_ids),
    val_idx = find(ARGS.exm_id_intervals(:,1)==ARGS.holdout_exm_ids(j));
    val_idx = ARGS.exm_id_intervals(val_idx,2):ARGS.exm_id_intervals(val_idx,3);
    val_obs_seq = ARGS.signal(:,val_idx);
    val_pred_path = decode_Viterbi(val_obs_seq, ARGS.transition_scores, ...
                                   ARGS.score_plifs, ARGS.PAR);
    val_true_label_seq = ARGS.label(val_idx);
    val_pred_label_seq = val_pred_path.label_seq;
    val_acc(j) = mean(val_true_label_seq(1,:)==val_pred_label_seq(1,:));
    
    if ARGS.PAR.verbose>=3 && j<=25,
      view_label_seqs(gcf, val_obs_seq, val_true_label_seq, val_pred_label_seq);
      title(gca, ['Hold-out example ' num2str(ARGS.holdout_exm_ids(j))]);
      fprintf('Hold-out example %i\n', ARGS.holdout_exm_ids(j));
      fprintf('  Example accuracy: %3.2f%%\n', 100*val_acc(j));
      pause
    end
  end
  fprintf(['  LSL validation accuracy:            %2.2f%%\n\n'], ...
          100*mean(val_acc));
  progress(iter).val_acc = val_acc';
end
fname = sprintf('progress_iter%i.mat', iter);
save([ARGS.PAR.out_dir fname], 'progress', 'iter');

t_stop_ac = clock();
fprintf('Performance checks took %3.2f sec\n\n', etime(t_stop_ac, t_start_ac));

if ARGS.PAR.verbose>=1,
  plot_progress(progress, ARGS.fh1);
  print(ARGS.fh1, '-depsc', [ARGS.PAR.out_dir 'progress.eps']);
  pause(1);
end    

