function progress = train_hmsvm(PAR)

% progress = train_hmsvm(PAR)
%
% Trains an HM-SVM.
%
% PAR -- a struct to configure the HM-SVM (for specification see
%   setup_hmsvm_training.m)
% returns a struct recording the training progress
%
% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany, 2008

% adjust set_hmsvm_paths.m to point to the correct directories
set_hmsvm_paths;

% include user-specified include paths
if isfield(PAR, 'include_paths'),
  for i=1:length(PAR.include_paths),
    addpath(PAR.include_paths{i});
  end
end

%%%%% initialize and chek PAR struct
PAR = set_default_par(PAR);

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

if ~exist('signal', 'var'),
  fn_data = PAR.data_file;
  if isequal(fn_data(end-3:end), '.mat'),
    fn_data = fn_data(1:end-4);
  end
  fn_data = [fn_data '_signal'];
  signal = load_struct(fn_data, 'signal');
end

if ~exist('exm_id', 'var'),
 load(PAR.data_file, 'exm_id_intervals');
 assert(exist('exm_id_intervals', 'var') ~= 0);
else
  unq_exm_id = unique(exm_id);
  exm_id_intervals = zeros(length(unq_exm_id),3);
  for i=1:length(unq_exm_id),
    idx = find(exm_id==unq_exm_id(i));
    exm_id_intervals(i,:) = [unq_exm_id(i), idx(1), idx(end)];
  end
  clear exm_id
end
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
  else
    holdout_exm_ids = [];
    fprintf('skipping performance estimation.\n\n');
    keyboard
  end
else
  % if training examples are not specified use all loaded sequences
  warning('No training set specified, treating whole data as training set!');
  assert(~isfield(PAR, 'vald_exms'));
  assert(~isfield(PAR, 'test_exms'));
  
  % randomize order of potential training example before subselection
  unq_exm_ids = unique(exm_id_intervals(:,1)');
  train_exm_ids = unq_exm_ids;
  train_exm_ids = train_exm_ids(randperm(length(train_exm_ids)));
  train_exm_ids = train_exm_ids(1:PAR.num_train_exm);
  fprintf('\nusing %i sequences for training.\n', ...
          length(train_exm_ids));
  % from the remainder take sequences for performance checks
  holdout_exm_ids = setdiff(unq_exm_ids, train_exm_ids);
  holdout_exm_ids = holdout_exm_ids(randperm(length(holdout_exm_ids)));
  assert(isempty(intersect(train_exm_ids, holdout_exm_ids)));
  fprintf('using %i sequences for performance estimation.\n\n', ...
          length(holdout_exm_ids));
end
% choose random subset for validation if there are too many
% validation examples
if length(holdout_exm_ids) > PAR.max_num_vald_exms,
  holdout_exm_ids = holdout_exm_ids(randperm(length(holdout_exm_ids)));
  holdout_exm_ids = holdout_exm_ids(1:PAR.max_num_vald_exms);
end
assert(isempty(intersect(train_exm_ids, holdout_exm_ids)));
fprintf('using %i sequences for performance estimation.\n\n', ...
        length(holdout_exm_ids));


%%%%% assemble model and score function structs,
LABELS = eval(sprintf('%s();', PAR.model_config.func_get_label_set));
state_model = eval(sprintf('%s(PAR);', PAR.model_config.func_make_model));
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
  idx = find(exm_id_intervals(:,1)==train_exm_ids(i));
  assert(~isempty(idx));
  idx = exm_id_intervals(idx,2):exm_id_intervals(idx,3);

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


%%%%% inititialize optimization problem 
opt_env = opt_license(1);
switch PAR.reg_type,
 case 'QP',
  [A b Q f lb ub slacks res res_map PAR] ...
      = init_QP(transition_scores, score_plifs, state_model, PAR);
 case 'LP',
  [A b f lb ub slacks res res_map PAR] ...
      = init_LP(transition_scores, score_plifs, state_model, PAR);
  how = opt_set_param(opt_env, 'CPX_PARAM_PREDUAL', 1, 1);
  assert(isequal(how, 'OK'));
  Q = []; % just to keep code as general as possible
 otherwise,
  error('Unknown reg_type: %s', PAR.reg_type);
end
assert(length(res) == PAR.num_opt_var);
assert(all(size(res_map) == size(score_plifs)));


%%%%% start iterative training
% iteration counter
iter = 1;
% a struct keeping track of training progress
progress = [];
% accuracy on training examples
trn_acc = zeros(1,length(train_exm_ids));
% previous value of the objective function
last_obj = 0;
% record elapsed time
t_start = clock();
if PAR.verbose > 1 && PAR.check_acc > 0,
  fh1 = figure;
end

idx = find(ismember(exm_id_intervals(:,1), train_exm_ids));
L = sum(exm_id_intervals(idx,3) - exm_id_intervals(idx,2) + 1);
fprintf('\nTraining on sequences with a total length of %i\n', L);

while iter<=PAR.max_num_iter,
  fprintf('\n\nIteration %i (%s):\n', iter, datestr(now,'yyyy-mm-dd_HHhMM'));
  new_constraints = zeros(1,PAR.num_train_exm);
  t_start_cg = clock();

  for i=1:length(train_exm_ids),
    idx = find(exm_id_intervals(:,1)==train_exm_ids(i));
    idx = exm_id_intervals(idx,2):exm_id_intervals(idx,3);
    obs_seq = signal(:,idx);
    true_label_seq = label(idx);
    true_state_seq = state_label(idx);
    
    %%% Viterbi decoding
    [pred_path true_path pred_path_mmv] ...
        = decode_Viterbi(obs_seq, transition_scores, score_plifs, ...
                         PAR, true_label_seq, true_state_seq);

    if PAR.extra_checks,
      w = weights_to_vector(pred_path.transition_weights, pred_path.plif_weights, ...
                            state_model, res_map, PAR);
      assert(abs(w*res(1:PAR.num_param) - pred_path.score) < PAR.epsilon);
  
      w = weights_to_vector(pred_path_mmv.transition_weights, ...
                            pred_path_mmv.plif_weights, state_model, ...
                            res_map, PAR);
      assert(abs(w*res(1:PAR.num_param) - pred_path_mmv.score) < PAR.epsilon);
    end
    
    w_p = weights_to_vector(true_path.transition_weights, ...
                            true_path.plif_weights, ...
                            state_model, res_map, PAR);
    w_n = weights_to_vector(pred_path_mmv.transition_weights, ...
                            pred_path_mmv.plif_weights, ...
                            state_model, res_map, PAR);
    
    if isfield(LABELS, 'ambiguous')
      eval_idx = true_path.label_seq ~= LABELS.ambiguous;
    else
      eval_idx = logical(ones(size(true_path.label_seq)));      
    end
    trn_acc(i) = mean(true_path.label_seq(eval_idx) ...
                      == pred_path.label_seq(eval_idx));

    weight_delta = w_p - w_n;
    assert(length(weight_delta) == PAR.num_param);

    loss = sum(pred_path_mmv.loss);
    if norm(weight_delta)==0, assert(loss < PAR.epsilon); end

    score_delta = weight_delta*res(1:PAR.num_param);
    
    %%% add constraints for examples which have not been decoded correctly
    %%% and for which a margin violator has been found
    if score_delta + slacks(i) < loss - PAR.epsilon && trn_acc(i)<PAR.max_accuracy,
      v = zeros(1,PAR.num_train_exm);
      v(i) = 1;
      A = [A; -weight_delta, zeros(1, PAR.num_aux), -v];
      b = [b; -loss];
      new_constraints(i) = 1;
    end
    
    if PAR.verbose > 2,
      fprintf('Training example %i\n', train_exm_ids(i));      
      fprintf('  example accuracy: %3.2f%%\n', 100*trn_acc(i));
      fprintf('  loss = %6.2f  diff = %8.2f  slack = %6.2f\n', ...
              loss, score_delta, slacks(i));
      if new_constraints(i),
        fprintf('  generated new constraint\n');      
      end
    end
  end
  fprintf('Generated %i new constraints\n', sum(new_constraints));
  t_stop_cg = clock();
  fprintf('Constraint generation took %3.2f sec\n', etime(t_stop_cg, t_start_cg));
  fprintf('Mean training accuracy (prior to solving): %2.1f%%\n\n', 100*mean(trn_acc));
 
  %%% solve intermediate optimization problem
  tic
  c_diff = b - A*res;
  part_idx = find(c_diff <= PAR.constraint_margin);
  fprintf('Solving problem with %2.1f%% of constraints\n\n', ...
          100*length(part_idx)/length(b));

  switch PAR.reg_type,
   case 'QP',
    [res, lambda, how] ...
        = qp_solve(opt_env, Q, f, sparse(A(part_idx,:)), b(part_idx), lb, ub, 0, 1, 'bar');
    if ~isequal(how, 'OK'),
      warning('Optimizer problem: %s',how);
    end
    obj = 0.5*res'*Q*res + f'*res;
   case 'LP',
    [res, lambda, how] ...
        = lp_solve(opt_env, f, sparse(A(part_idx,:)), b(part_idx), lb, ub, 0, 1, 'bar');
    if ~isequal(how, 'OK'),
      warning('Optimizer problem: %s', how);
    end
    obj = f'*res;
   otherwise,
    error('Unknown reg_type: %s', PAR.reg_type);
  end
  fprintf('\nSolving the optimization problem took %3.2f sec\n', toc);
  assert(length(res) == PAR.num_param+PAR.num_aux+PAR.num_train_exm);
  slacks = res(end-PAR.num_train_exm+1:end);
  diff = obj - last_obj;
  % warning if objective is not monotonically increasing
  if diff < -PAR.epsilon,
    warning('Decrease in objective function %f by %f', obj, diff);
  end
  last_obj = obj;
  fprintf('  objective = %1.6f (diff = %1.6f), sum_slack = %1.6f\n', ...
          obj, diff, sum(slacks));
  fprintf('  %.1f%% of constraints satisfied\n\n', ...
          100*mean(A*res <= b+PAR.epsilon));

  %%% extract parameters from optimization problem & update model 
  %%% (i.e. transition scores & score PLiFs)
  [transition_scores, score_plifs] = res_to_scores(res, state_model, res_map, ...
                                                   score_plifs, PAR);
  
  progress(iter).gen_constraints = new_constraints';
  progress(iter).objective = obj;
  progress(iter).el_time = etime(clock(), t_start);

  %%% check prediction accuracy on training and holdout examples;
  %%% accuracy check can be run as an independent job
  if PAR.check_acc,
    ARGS = [];
    ARGS.PAR = PAR;
    ARGS.train_exm_ids = train_exm_ids;
    ARGS.holdout_exm_ids = holdout_exm_ids;
    ARGS.exm_id_intervals = exm_id_intervals;
    ARGS.signal = signal;
    ARGS.label = label;
    ARGS.transition_scores = transition_scores;
    ARGS.score_plifs = score_plifs;
    ARGS.progress = progress;
    ARGS.iter = iter;
    if PAR.verbose > 1,
      ARGS.fh1 = fh1;
    end
    if PAR.submit_vald > 0,
      rproc_opt            = [];
      rproc_opt.priority   = 17;
      rproc_opt.identifier = sprintf('hmsvm_acc_');
      rproc_opt.verbosity  = 0;
      rproc_opt.start_dir  = PAR.include_paths{1};
      rproc_opt.addpaths   = PAR.include_paths;
      rproc_memreq         = 1700;
      rproc_time           = length(train_exm_ids) + length(holdout_exm_ids);
      rproc('check_accuracy', ARGS, rproc_memreq, rproc_opt, rproc_time);
      fprintf('Submitted job for performance checking\n\n');
   else
      check_accuracy(ARGS);
    end
  end
  
  if PAR.verbose>=3,
    eval(sprintf('%s(state_model, score_plifs, PAR, transition_scores);', ...
                 PAR.model_config.func_view_model));
  end  

  % save at every fifth iteration
  if mod(iter,5)==0,
    fprintf('Saving intermediate result...\n\n\n');
    fname = sprintf('lsl_iter%i', iter);
    save('-v7',[PAR.out_dir fname], 'PAR', 'state_model', 'score_plifs', 'transition_scores', ...
         'trn_acc', 'A', 'b', 'Q', 'f', 'lb', 'ub', 'slacks', 'res', ...
         'train_exm_ids', 'holdout_exm_ids', 'progress');
  end
  
  %%% save and terminate training if no more constraints are generated or
  %%% the change of the objective function over the last three iterations
  %%% was unsubstantial
  if all(new_constraints==0) ...
        || (iter>3 && obj-progress(iter-3).objective < obj*PAR.min_rel_obj_change),

    fprintf('Saving final result...\n\n\n');
    fname = sprintf('lsl_final');
    save('-v7',[PAR.out_dir fname], 'PAR', 'state_model', 'score_plifs', 'transition_scores', ...
         'trn_acc', 'A', 'b', 'Q', 'f', 'lb', 'ub', 'slacks', 'res', ...
         'train_exm_ids', 'holdout_exm_ids', 'progress');

    if PAR.verbose>=2,
      eval(sprintf('%s(state_model, score_plifs, PAR, transition_scores);', ...
                   PAR.model_config.func_view_model));
      figure
      plot(res)
      pause(1)
    end

    % terminate optimizer and exit
    opt_close(opt_env);
    return
  end
  iter = iter + 1;
end

% eof
