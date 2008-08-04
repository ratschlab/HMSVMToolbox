% Starts HM-SVM training (calling train_hmsvm.m) for different
% combination of hyperparameters. Can thus be used for cross-validation
% and model selection.
%
% see train_hmsvm.m
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008

USE_RPROC = 0;

crossvalidation_subsets = [1, 2, 3, 4, 5];

param_names = {'C_small', 'C_smooth', 'C_coupling', ...
               'num_exm', 'train_subsets', 'optimization'}

parameters = { ...
    [10],  [10], [5], [100], [1], 'LP'; ...
%    [5],  [10], [5], [100], [1], 'QP'; ...
%    [0.1], [1], [5], [100], [1], 'QP'; ...
             };

dr_base = ['~/hmsvm_toydata/segmentation/'...
           'hmsvm_result_' datestr(now,'yyyy-mm-dd_HHhMM')]

data_file = '~/hmsvm_toydata/hmsvm_data.mat';

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
  
  % parameters for which the best model is selected
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
  
  if isfield(PAR, 'train_subsets'),
    assert(all(ismember(PAR.train_subsets, crossvalidation_subsets)));
    holdout_subsets = setdiff(crossvalidation_subsets, PAR.train_subsets);
    assert(length(holdout_subsets)>=2);
    PAR.vald_subsets = holdout_subsets(1);
    PAR.test_subsets = holdout_subsets(2:end);
  end
  disp(PAR)

  if USE_RPROC,
    % RPROC settings
    RPROC_MEMREQ             = 2000;
    RPROC_OPT.express        = 0;
    RPROC_OPT.immediately_bg = 0;
    RPROC_OPT.immediately    = 0;
    RPROC_OPT.arch           = 64; % take only 64 bit nodes
    RPROC_OPT.identifier     = sprintf('hmsvm_tr_m%i_',i);
    RPROC_TIME               = 12*(PAR.num_exm/100)*60; % mins
    
    JOB_INFO{end+1} = rproc('train_hmsvm', ...
                            PAR, RPROC_MEMREQ, RPROC_OPT, RPROC_TIME);
    fprintf('\nSubmitted job %i\n\n', length(JOB_INFO));
  else
    train_hmsvm(PAR);
  end
end