function progress = train_hmm_baseline(PAR)

% progress = train_hmm_baseline(PAR)
%
% Trains a baseline HMM.
%
% PAR -- a struct to configure the HMM (for specification see
%   setup_hmsvm_training.m)
% returns a struct summarizing training accuracy
%
% see train_hmsvm.m
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008

% adjust set_hmsvm_paths.m to point to the correct directories
% use the same include paths for HMM and HM-SVM
set_hmsvm_paths();

% include user-specified include paths
if isfield(PAR, 'include_paths'),
  for i=1:length(PAR.include_paths),
    addpath(PAR.include_paths{i});
  end
end

% option to enable/disable some extra consistency checks
if ~isfield(PAR, 'extra_checks'),
  PAR.extra_checks = 0;
end

% option to control the amount of output
if ~isfield(PAR, 'verbose'),
  PAR.verbose = 2;
end

if PAR.verbose>=1,
  fh1 = figure;
end

% subsample examples for performance checks
if ~isfield(PAR, 'max_num_vald_exms'),
  PAR.max_num_vald_exms = 100;
end

% numerical tolerance to check consistent score calculation
if ~isfield(PAR, 'epsilon'),
  PAR.epsilon = 10^-6;
end

% seed for random number generation
rand('seed', 11081979);

% mandatory fields of the parameter struct
assert(isfield(PAR, 'num_train_exm'));
assert(isfield(PAR, 'data_file'));
assert(isfield(PAR, 'out_dir'));
assert(isfield(PAR, 'model_dir'));

if ~exist(PAR.out_dir, 'dir'),
  mkdir(PAR.out_dir);
end

%%%%% init state model
if exist(PAR.model_name)~=7,
  addpath(PAR.model_dir);
end
PAR.model_config = model_config();
assert(isequal(PAR.model_name, PAR.model_config.name));
disp(PAR);
disp(PAR.data_file);


%%%%% load data and select training examples
load(PAR.data_file, 'label', 'signal', 'exm_id');
state_label = nan(size(label));
PAR.num_features = size(signal,1);

if isfield(PAR, 'train_exms'),
  % randomize order of potential training example before subselection
  train_exm_ids = PAR.train_exms;
  train_exm_ids = train_exm_ids(randperm(length(train_exm_ids)));
  train_exm_ids = train_exm_ids(1:PAR.num_train_exm);
  fprintf('\nusing %i sequences for training.\n', ...
          length(train_exm_ids));
  % for performance checks use sequences from validation set if given
  if isfield(PAR, 'vald_exms'),
    holdout_exm_ids = PAR.vald_exms;
    % choose random subset for validation if there are too many
    % validation examples
    if length(holdout_exm_ids) > PAR.max_num_vald_exms,
      holdout_exm_ids = holdout_exm_ids(randperm(length(holdout_exm_ids)));
      holdout_exm_ids = holdout_exm_ids(1:PAR.max_num_vald_exms);
    end
    assert(isempty(intersect(train_exm_ids, holdout_exm_ids)));
    fprintf('using %i sequences for performance estimation.\n\n', ...
            length(holdout_exm_ids));
  else
    holdout_exm_ids = [];
    fprintf('skipping performance estimation.\n\n');
  end
else
  % if training examples are not specified use all loaded sequences
  warning('No training set specified, treating whole data as training set!');
  assert(~isfield(PAR, 'vald_exms'));
  assert(~isfield(PAR, 'test_exms'));
  
  % randomize order of potential training example before subselection
  train_exm_ids = unique(exm_id);
  train_exm_ids = train_exm_ids(randperm(length(train_exm_ids)));
  train_exm_ids = train_exm_ids(1:PAR.num_train_exm);
  fprintf('\nusing %i sequences for training.\n', ...
          length(train_exm_ids));
  % from the remainder take sequences for performance checks
  holdout_exm_ids = setdiff(unique(exm_id), train_exm_ids);
  holdout_exm_ids = holdout_exm_ids(randperm(length(holdout_exm_ids)));
  assert(isempty(intersect(train_exm_ids, holdout_exm_ids)));
  fprintf('using %i sequences for performance estimation.\n\n', ...
          length(holdout_exm_ids));
end


%%%%% assemble model and score function structs,
LABELS = eval(sprintf('%s;', PAR.model_config.func_get_label_set));
state_model = eval(sprintf('%s(PAR);', ...
                           PAR.model_config.func_make_model));

[score_plifs transition_scores] = eval(sprintf('%s(signal, label, state_model, PAR);', ...
                                               PAR.model_config.func_init_parameters));
assert(~any(isnan([score_plifs.limits])));
assert(~any(isnan([score_plifs.scores])));
assert(~any(isnan(transition_scores)));

%%%%% determine the true state sequence for each example from its label sequence
if isfield(PAR, 'label_noise_prop') && PAR.label_noise_prop > 0,
  noise_cnt = 0;
end
for i=1:length(train_exm_ids),
  idx = find(exm_id==train_exm_ids(i));
  if isfield(PAR, 'label_noise_prop') && PAR.label_noise_prop > 0,
    [label(idx) cnt] = add_label_noise(label(idx), PAR);
    noise_cnt = noise_cnt + cnt;
  end 
  true_label_seq = label(idx);
  obs_seq = signal(:,idx);
  true_state_seq = eval(sprintf('%s(true_label_seq, state_model, obs_seq, PAR);', ...
                                PAR.model_config.func_labels_to_states));
  if PAR.extra_checks,
    assert(check_path(true_state_seq, state_model));
  end
  state_label(idx) = true_state_seq;
end
if isfield(PAR, 'label_noise_prop') && PAR.label_noise_prop > 0,
  fprintf('  converted %i segments (label noise level: %2.1f%%)\n', noise_cnt, ...
          100*PAR.label_noise_prop);
end


%%%%% start training
% a struct keeping track of training progress
progress = [];
% accuracy on training examples
trn_acc = zeros(1,length(train_exm_ids));
% accuracy on holdout validation examples
val_acc = zeros(1,length(holdout_exm_ids));
% record elapsed time
t_start = clock();

tic
% compute mapping (features, states) -> position in one-dimensional vector
PAR.num_trans_score = length(transition_scores);
next_score_start = length(transition_scores)+1;
res_map = zeros(PAR.num_features, length(state_model));
cnt = 1;
for i=1:length(state_model), % for all states
  idx = find(state_model(i).learn_scores);
  for j=1:length(idx),
    row_idx = state_model(i).feature_scores(j,1);
    col_idx = state_model(i).feature_scores(j,2);
    if res_map(row_idx, col_idx) == 0,
      res_map(row_idx, col_idx) = next_score_start;
      score_starts(cnt) = next_score_start;
      next_score_start = next_score_start + PAR.num_plif_nodes;
      cnt = cnt + 1;
    end
  end
end
PAR.num_param = next_score_start - 1;
assert(PAR.num_features == size(score_plifs,1));
assert(length(state_model) == size(score_plifs,2));
assert(PAR.num_features == size(res_map,1));
assert(length(state_model) == size(res_map,2));


%%% do one round of Viterbi decoding for all training examples to count
%%% transitions and feature values
W = zeros(1, PAR.num_param);
for i=1:length(train_exm_ids),
  idx = find(exm_id==train_exm_ids(i));
  obs_seq = signal(:,idx);
  true_label_seq = label(idx);
  true_state_seq = state_label(idx);
    
  [tmp true_path] = decode_Viterbi(obs_seq, transition_scores, score_plifs, ...
                                   PAR, true_label_seq, true_state_seq);
  W = W + weights_to_vector(true_path.transition_weights, ...
                            true_path.plif_weights, state_model, ...
                            res_map, PAR);
end
fprintf('Decoded %i training sequences\n\n', length(train_exm_ids));
fprintf('Decoding took %3.2f sec\n\n', toc);


%%% add pseudo counts
if ~isfield(PAR, 'hmm_pseudo_cnt');
  pseudo_cnt = 1;
else
  pseudo_cnt = PAR.hmm_pseudo_cnt;  
end
W(W<pseudo_cnt) = pseudo_cnt;
% this does not work as well
%W = W + pseudo_cnt;

%%% compute transition scores as transition frequencies
for i=1:length(state_model),
  idx = state_model(i).trans_scores;
  % LOG-TRANSFORM scores as Viterbi assumes ADDITIVE scores
  transition_scores(idx) = log(W(idx) ./ sum(W(idx)));
end

%%% compute feature scoring function values as frequencies of occurrence in
%%% true paths (accumulated in W)
for i=1:size(res_map,1), % for all features
  for j=1:size(res_map,2), % for all states
    if res_map(i,j) ~= 0,
      idx = res_map(i,j):res_map(i,j)+PAR.num_plif_nodes-1; 
      % LOG-TRANSFORM scores as Viterbi assumes ADDITIVE scores
      score_plifs(i,j).scores = log(W(idx) ./ sum(W(idx)));
    end
  end
end

progress.el_time = etime(clock(), t_start);


%%% check prediction accuracy on training examples
for j=1:length(train_exm_ids),
  trn_idx = find(exm_id==train_exm_ids(j));
  trn_obs_seq = signal(:,trn_idx);
  trn_true_label_seq = label(trn_idx);
  trn_true_state_seq = state_label(trn_idx);
  [trn_pred_path trn_true_path] = decode_Viterbi(trn_obs_seq, transition_scores, score_plifs, ...
                                                 PAR, trn_true_label_seq, trn_true_state_seq);
  trn_pred_label_seq = trn_pred_path.label_seq;
  trn_acc(j) = mean(trn_true_label_seq(1,:)==trn_pred_label_seq(1,:));
  
  if PAR.verbose>=3 && j<=25,
    view_label_seqs(gcf, trn_obs_seq, trn_true_label_seq, trn_pred_label_seq);
    title(gca, ['Training example ' num2str(train_exm_ids(j))]);
    fprintf('Training example %i\n', train_exm_ids(j));
    fprintf('  Example accuracy: %3.2f%%\n', 100*trn_acc(j));
    pause
  end
end
fprintf('  HMM training accuracy:              %2.2f%%\n', ...
        100*mean(trn_acc));
progress.trn_acc = trn_acc';

%%% check prediction accuracy on holdout examples
if ~isempty(holdout_exm_ids),
  for j=1:length(holdout_exm_ids),
    val_idx = find(exm_id==holdout_exm_ids(j));
    val_obs_seq = signal(:,val_idx);
    val_pred_path = decode_Viterbi(val_obs_seq, transition_scores, score_plifs, PAR);
    val_true_label_seq = label(val_idx);
    val_pred_label_seq = val_pred_path.label_seq;
    val_acc(j) = mean(val_true_label_seq(1,:)==val_pred_label_seq(1,:));
    
    if PAR.verbose>=3 && j<=25,
      view_label_seqs(gcf, val_obs_seq, val_true_label_seq, val_pred_label_seq);
      title(gca, ['Hold-out example ' num2str(holdout_exm_ids(j))]);
      fprintf('Hold-out example %i\n', holdout_exm_ids(j));
      fprintf('  Example accuracy: %3.2f%%\n', 100*val_acc(j));
      pause
    end
  end
  fprintf('  HMM validation accuracy:            %2.2f%%\n\n', ...
          100*mean(val_acc));
  progress.val_acc = val_acc';
end

if PAR.verbose>=1,
  plot_progress(progress, fh1);
  pause(1);
end    

if PAR.verbose>=3,
  eval(sprintf('%s(state_model, score_plifs, PAR, transition_scores);', ...
               PAR.model_config.func_view_model));
end  

% save results
fprintf('Saving result...\n\n\n');
fname = sprintf('hmm_training_minl%i', PAR.hmm_min_level);
save([PAR.out_dir fname], 'PAR', 'state_model', 'score_plifs', 'transition_scores', ...
     'trn_acc', 'val_acc', 'train_exm_ids', 'holdout_exm_ids', 'progress');

% eof