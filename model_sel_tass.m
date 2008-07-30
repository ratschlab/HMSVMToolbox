% Model selection script that calls main_training.m for each specified
% combination of hyperparameters. 
%
% Written by Georg Zeller, MPI Tuebingen, Germany, 2008

USE_RPROC = 0;

crossvalidation_subsets = [1, 2, 3, 4, 5];

param_names = {'C_small', 'C_smooth', 'C_coupling', ...
               'num_exm', 'train_subsets', 'optimization'}

parameters = { ...
    [0.005],  [0.05], [1], [250], [1, 2, 3], 'LP'; ...
    [0.01],  [0.05], [1], [250], [1, 2, 3], 'QP'; ...
%    [0.1], [1], [5], [100], [1, 2, 3], 'QP'; ...
             };

dr_base = '/fml/ag-raetsch/share/projects/tiling_arrays/ta_splice_simulations/';

data_file = [dr_base 'ta_splice_data.mat'];
dr_base = [dr_base 'hmsvm_result_' datestr(now,'yyyy-mm-dd_HHhMM')];

% partition exon intensities into expression bins 
% (i.e. assign discrete expression levels) 
NUM_LEVELS = 10;
load(data_file, 'signal', 'label');
EXPRESSION_BINS = discretize_expression(signal, label, NUM_LEVELS);
assert(size(EXPRESSION_BINS,1) == NUM_LEVELS);

JOB_INFO = [];
for i=1:size(parameters,1),
  PAR = [];
  % constant parameters
  PAR.out_dir = [dr_base '_model' num2str(i) '/'];
  PAR.model_name = 'ta_splice_multi_level';
  PAR.model_dir = ['models/' PAR.model_name '/'];
  PAR.data_file = data_file;
  PAR.num_plif_nodes = 20;

  % constant parameters specificic to mSTADsplice
  PAR.NUM_LEVELS = NUM_LEVELS;
  PAR.EXPRESSION_BINS = EXPRESSION_BINS;
  
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
  else
    train_hmsvm(PAR);
  end
  
  fprintf('\nSubmitted job %i\n\n', length(JOB_INFO));
end