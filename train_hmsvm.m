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
set_hmsvm_paths();

%profile on

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
  PAR.verbose = 1;
end
if PAR.verbose>=1,
  fh1 = figure;
end

% option to enable/disable performance checks during training
if ~isfield(PAR, 'check_acc'),
  PAR.check_acc = 1;
end

% stopping criterion: constraint generation is terminated if no more
% margin violations are found or the relative change of the objective
% function is smaller than this parameter...
if ~isfield(PAR, 'min_rel_obj_change'),
  PAR.min_rel_obj_change = 10^-3;
end
% ... or if the maximum number of iterations is exceeded
if ~isfield(PAR, 'max_num_iter'),
  PAR.max_num_iter = 1000;
end

% margin constraints are only added if the example is predicted with an
% accuracy below this parameter
if ~isfield(PAR, 'max_accuracy'),
  PAR.max_accuracy = 0.99;
end
% and if the max margin violator incurs a loss at least as high as this
% parameter
if ~isfield(PAR, 'min_loss'),
  PAR.min_loss = 1;
end

% numerical tolerance to check consistent score calculation, constraint
% satisfaction and monotonictiy of the objective function
if ~isfield(PAR, 'epsilon'),
  PAR.epsilon = 10^-6;
end

% option to only solve partial intermediate training problems which do
% not contain constraints satisfied with a margin at least as large as
% the parameter value. Such constraints are however kept aside and
% checked in each iteration. Set to inf to always solve the full problem.
% Throwing away constraints is a HEURISTIC which speeds up training at
% the cost of losing the guarantee to converge to the correct solution!
if ~isfield(PAR, 'constraint_margin'),
  PAR.constraint_margin = inf;
end

% optimization software used to solve the (intermediate) training
% problem(s). Currently there are two possibilities: 'cplex' or 'mosek'
if ~isfield(PAR, 'optimizer'),
  PAR.optimizer = 'cplex' % one of 'cplex' or 'mosek'
  % path to the optimizer interface
  addpath(sprintf('opt_interface/%s', PAR.optimizer));
end

% subsample examples for performance checks
if ~isfield(PAR, 'max_num_vald_exms'),
  PAR.max_num_vald_exms = 100;
end

% by default, do not submit any cluster jobs from within HM-SVM training
if ~isfield(PAR, 'submit_jobs'),
  PAR.submit_jobs = 0;
end


% seed for random number generation
rand('seed', 11081979);

% mandatory fields of the parameter struct
assert(isfield(PAR, 'C_small'));
assert(isfield(PAR, 'C_smooth'));
assert(isfield(PAR, 'C_coupling'));
assert(isfield(PAR, 'num_train_exm'));
assert(isfield(PAR, 'data_file'));
assert(isfield(PAR, 'out_dir'));
assert(isfield(PAR, 'model_dir'));
assert(isfield(PAR, 'reg_type'));

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
if ~exist('exm_id', 'var'),
 load(PAR.data_file, 'exm_id_intervals');
 assert(exist('exm_id_intervals', 'var') ~= 0);
else
  unq_exm_id = unique(exm_id);
  exm_id_intervals = zeros(unq_exm_id,3);
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
state_model = eval(sprintf('%s(PAR);', ...
                           PAR.model_config.func_make_model));

[score_plifs transition_scores] = eval(sprintf('%s(signal, label, state_model, PAR);', ...
                                               PAR.model_config.func_init_parameters));
assert(~any(isnan([score_plifs.limits])));
assert(~any(isnan([score_plifs.scores])));
assert(~any(isnan(transition_scores)));

%%%%% determine the true state sequence for each example from its label sequence
for i=1:length(train_exm_ids),
  idx = find(exm_id_intervals(:,1)==train_exm_ids(i));
  assert(~isempty(idx));
  idx = exm_id_intervals(idx,2):exm_id_intervals(idx,3);
  true_label_seq = label(idx);
  obs_seq = signal(:,idx);
  true_state_seq = eval(sprintf('%s(true_label_seq, state_model, obs_seq, PAR);', ...
                                PAR.model_config.func_labels_to_states));
  if PAR.extra_checks,
    assert(check_path(true_state_seq, state_model));
  end
  state_label(idx) = true_state_seq;
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
% a struct keeping track of training progress
progress = [];
% accuracy on training examples
trn_acc = zeros(1,length(train_exm_ids));
% previous value of the objective function
last_obj = 0;
% record elapsed time
t_start = clock();

rproc_submit=1 ;
rproc_mem=2000 ; % in MB
rproc_options=[] ;
rproc_options.priority=100 ;
rproc_time=10 ; % in minutes

for iter=1:PAR.max_num_iter,
  fprintf('\n\nIteration %i:\n', iter);
  new_constraints = zeros(1,PAR.num_train_exm);
  t_start_cg = clock();

  jobinfo = rproc_empty(0) ;
  for i=1:length(train_exm_ids)
    idx = find(exm_id_intervals(:,1)==train_exm_ids(i));
    idx = exm_id_intervals(idx,2):exm_id_intervals(idx,3);
    obs_seq = signal(:,idx);
    true_label_seq = label(idx);
    true_state_seq = state_label(idx);
    
    rproc_PAR=[] ;
    rproc_PAR.obs_seq=obs_seq ;
    rproc_PAR.transition_scores=transition_scores ;
    rproc_PAR.score_plifs=score_plifs ;
    rproc_PAR.PAR=PAR ;
    rproc_PAR.true_label_seq=true_label_seq ;
    rproc_PAR.true_state_seq=true_state_seq ;
    rproc_PAR.state_model=state_model ;
    rproc_PAR.res_map=res_map ;
    rproc_PAR.true_path=true_path ;
    rproc_PAR.res=res ;

    if rproc_submit==0,
      res_PAR{i} = gen_path(rproc_PAR) ;
    else
      jobinfo(i)=rproc('gen_path', rproc_PAR, rproc_mem, rproc_options, rproc_time) ;
    end ;
  end ;

  if rproc_submit~=0,
    [jobinfo, num_crashed] = rproc_wait(jobinfo, 10, 1, 0);
    if num_crashed>0,
      fprintf('%i jobs crashed\n', num_crashed) ;
    end ;
    
    for i=1:length(train_exm_ids)
      try,
        res_PAR{i}=rproc_result(jobinfo(i)) ;
        rproc_cleanup(jobinfo(i)) ;
      catch
        fprintf('obtaining result for job %i failed\n', i) ;
        res_PAR{i}=[] ;
      end ;
    end ;

  end ;

  for i=1:length(train_exm_ids)
    %idx = find(exm_id_intervals(:,1)==train_exm_ids(i));
    %idx = exm_id_intervals(idx,2):exm_id_intervals(idx,3);
    %obs_seq = signal(:,idx);
    %true_label_seq = label(idx);
    %true_state_seq = state_label(idx);

    if isempty(res_PAR{i})
      continue ;
    end ;

    pred_path=res_PAR{i}.pred_path ;
    true_path=res_PAR{i}.true_path ;
    pred_path_mmv=res_PAR{i}.pred_path_mmv ;
    w=res_PAR{i}.w ;
    w_p=res_PAR{i}.w_p ;
    w_n=res_PAR{i}.w_n ;

    trn_acc(i) = mean(true_path.label_seq==pred_path.label_seq);

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
    
    if PAR.verbose>=3,
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
      error('Optimizer problem: %s',how);
    end
    obj = 0.5*res'*Q*res + f'*res;
   case 'LP',
    [res, lambda, how] ...
        = lp_solve(opt_env, f, sparse(A(part_idx,:)), b(part_idx), lb, ub, 0, 1, 'bar');
    if ~isequal(how, 'OK'),
      error('Optimizer problem: %s', how);
    end
    obj = f'*res;
   otherwise,
    error('Unknown reg_type: %s', PAR.reg_type);
  end
  fprintf('\nSolving the optimization problem took %3.2f sec\n', toc);
  assert(length(res) == PAR.num_param+PAR.num_aux+PAR.num_train_exm);
  slacks = res(end-PAR.num_train_exm+1:end);
  diff = obj - last_obj;
  % error if objective is not monotonically increasing
  if diff < -PAR.epsilon,
    error('Decrease in objective function %f by %f', obj, diff);
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

  %%% check prediction accuracy on training examples
  if PAR.check_acc,
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
    if PAR.verbose>=1,
      ARGS.fh1 = fh1;
    end
    if PAR.submit_jobs > 0,
      rproc_par.priority   = 17;
      rproc_par.identifier = sprintf('hmsvm_acc_');
      rproc_par.verbosity  = 0;
      rproc_par.start_dir  = PAR.include_paths{1};
      rproc_memreq         = 2200;
      rproc_time           = length(train_exm_ids) + length(holdout_exm_ids);
      rproc('check_accuracy', ARGS, rproc_memreq, rproc_par, rproc_time);
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
    save([PAR.out_dir fname], 'PAR', 'state_model', 'score_plifs', 'transition_scores', ...
         'trn_acc', 'A', 'b', 'Q', 'f', 'lb', 'ub', 'slacks', 'res', ...
         'train_exm_ids', 'holdout_exm_ids');
  end
  
  %%% save and terminate training if no more constraints are generated or
  %%% the change of the objective function over the last three iterations
  %%% was unsubstantial
  if all(new_constraints==0) ...
        || (iter>3 && obj-progress(iter-3).objective < obj*PAR.min_rel_obj_change),
    fprintf('Saving final result...\n\n\n');
    fname = sprintf('lsl_final');
    save([PAR.out_dir fname], 'PAR', 'state_model', 'score_plifs', 'transition_scores', ...
         'trn_acc', 'A', 'b', 'Q', 'f', 'lb', 'ub', 'slacks', 'res', ...
         'train_exm_ids', 'holdout_exm_ids');

    if PAR.verbose>=2,
      eval(sprintf('%s(state_model, score_plifs, PAR, transition_scores);', ...
                   PAR.model_config.func_view_model));
      figure
      plot(res)
      pause(1)
    end

    % terminate optimizer and return
    opt_close(opt_env);
    return
  end
%  profview
end

% eof