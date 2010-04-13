% Starts HM-SVM training (calling train_hmsvm.m) for different
% combination of hyperparameters. Can thus be used for cross-validation
% and model selection.
%
% see train_hmsvm.m
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008

% option to use rproc tools to submit training jobs to a cluster
USE_RPROC = 0;

% number of subsets used for cross-validation
num_xval_subsets = 5;

% names of parameters to be independently specified (possibly differently
% between training runs) 
param_names = {'C_small', ...
               'C_smooth', ...
               'C_coupling', ...
               'num_train_exm', ...
               'reg_type'...
               'train_subsets', ...
              };

% parameter combinations to be used for independent training
parameters = { ...
%    [0.1],  [5], [5], [100], 'LP', [1]; ...
    [5] ,  [10], [5], [100], 'QP', [1]; ...
    [5] ,  [10], [5], [100], 'QP', [3]; ...
%    [0.1],  [1], [5], [100], 'QP', [1]; ...
             };
assert(size(parameters,2) == length(param_names));

% basic data directory
dr_base = ['hmsvm_toydata/segmentation/'...
           'hmsvm_result_' datestr(now,'yyyy-mm-dd_HHhMM')]

% seed for random number generation
rand('seed', 11081979);

% partition data for cross-validation
data_file = 'hmsvm_toydata/hmsvm_data.mat';
load(data_file, 'exm_id');
exm_id = unique(exm_id);
exm_id = exm_id(randperm(length(exm_id)));
subset_ends = round(linspace(0,length(exm_id),num_xval_subsets+1));
for i=1:num_xval_subsets,
  exm_subsets{i} = sort(exm_id(subset_ends(i)+1:subset_ends(i+1)));
end
assert(isequal(sort([exm_subsets{:}]), sort(exm_id)));

JOB_INFO = [];
for i=1:size(parameters,1),
  PAR = [];
  % constant parameters
  PAR.out_dir = [dr_base '_model' num2str(i) '/']; % output directory
  PAR.model_name = 'two_state';                    % name of the learning model
  PAR.model_dir = ['models/' PAR.model_name '/'];  % model directory
  PAR.data_file = data_file;                       % name of the training data file
  PAR.num_plif_nodes = 20;                         % number of supporting points
                                                   % for each scoring function
  PAR.constraint_margin = 10;                      % use heuristic training procedure
  PAR.verbose = 1;
  PAR.optimizer = optimizer_choice;
  
  % parameters which vary across HM-SVM training runs
  fprintf('Training model %i...\n', i);
  for j=1:length(param_names),
    if length(parameters{i,j}) == 1,
      fprintf('  %s = %f\n', param_names{j}, parameters{i,j});
    else
      p_str = [];
      for k=1:length(parameters{i,j}),
        p_str = [p_str sprintf('%f ', parameters{i,j}(k))];
      end
      fprintf('  %s = %s\n', param_names{j}, p_str);
    end
    PAR = setfield(PAR, param_names{j}, parameters{i,j});
  end
  fprintf('\n\n');

  % assign example sequences to training, validation and test set
  assert(isfield(PAR, 'train_subsets'));
  PAR.vald_subsets = PAR.train_subsets(end)+1;
  if PAR.vald_subsets>num_xval_subsets,
    PAR.vald_subsets = mod(PAR.vald_subsets,num_xval_subsets);
  end
  assert(all(ismember(PAR.train_subsets, [1:num_xval_subsets])));
  assert(all(ismember(PAR.vald_subsets,  [1:num_xval_subsets])));
  PAR.test_subsets = setdiff(1:num_xval_subsets, ...
                             [PAR.train_subsets PAR.vald_subsets]);
  PAR.train_exms = [exm_subsets{PAR.train_subsets}];
  PAR.vald_exms  = [exm_subsets{PAR.vald_subsets}];
  PAR.test_exms  = [exm_subsets{PAR.test_subsets}];
  assert(isempty(intersect(PAR.train_exms, PAR.vald_exms)));
  assert(isempty(intersect(PAR.test_exms, [PAR.train_exms, PAR.vald_exms])));
  assert(length(PAR.train_exms) >= PAR.num_train_exm);
  
  disp(PAR)

  if USE_RPROC,
    % RPROC settings
    RPROC_MEMREQ             = 2000;
    RPROC_OPT.express        = 0;
    RPROC_OPT.immediately_bg = 0;
    RPROC_OPT.immediately    = 0;
    RPROC_OPT.arch           = 64; % take only 64 bit nodes
    RPROC_OPT.identifier     = sprintf('hmsvm_tr_m%i_',i);
    RPROC_TIME               = 12*(PAR.num_train_exm/100)*60; % mins
    
    JOB_INFO{end+1} = rproc('train_hmsvm', ...
                            PAR, RPROC_MEMREQ, RPROC_OPT, RPROC_TIME);
    fprintf('\nSubmitted job %i\n\n', length(JOB_INFO));
  else
    train_hmsvm(PAR);
  end
end

% eof
