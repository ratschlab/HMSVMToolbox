% model selection
param_names = {'C_small', 'C_smooth', 'C_coupling', ...
               'num_exm', 'train_subsets'}

parameters = [ ...
    1,  10,   0,  10, 1; ...
             ];

assert(size(parameters,2) == length(param_names));

dr_base = ['/fml/ag-raetsch/share/projects/enhancer/segmentation/'...
           'hmsvm_result_' datestr(now,'yyyy-mm-dd_HHhMM')]

data_file = ['/fml/ag-raetsch/share/projects/enhancer/data/' ...
             'hmsvm_data.mat'];

JOB_INFO = [];
for i=1:size(parameters,1),
  fprintf('Training model %i...\n', i);
  for j=1:length(param_names),
    fprintf('  %s = %f\n', param_names{j}, parameters(i,j));
  end
  fprintf('\n\n');
  
  PAR = [];
  % constant parameters
  PAR.out_dir = [dr_base '_model' num2str(i) '/'];
  PAR.model_dir = 'models/two_state/';
  PAR.data_file = data_file;
  PAR.num_plif_nodes = 20;
  
  % parameters for which the best model is selected
  for j=1:length(param_names),
    PAR = setfield(PAR, param_names{j}, parameters(i,j));    
  end
  
  if isfield(PAR, 'train_subsets'),
    PAR.vald_subsets = mod(PAR.train_subsets,5) + 1;
    PAR.test_subsets = setdiff([1 2 3 4 5], ...
                               [PAR.train_subsets PAR.vald_subsets]);
  end
  disp(PAR)
  
  % RPROC settings
  RPROC_MEMREQ             = 2000;
  RPROC_OPT.express        = 0;
  RPROC_OPT.immediately_bg = 0;
  RPROC_OPT.immediately    = 0;
  RPROC_OPT.arch           = 64; % take only 64 bit nodes
  RPROC_OPT.identifier     = sprintf('GZ_TrES_model%i_',i);
  RPROC_TIME               = 12*(PAR.num_exm/100)*60; % mins
  
%  JOB_INFO{end+1} = rproc('main_training', ...
%                          PAR, RPROC_MEMREQ, RPROC_OPT, RPROC_TIME);

% FOR DEBUGGING
  main_training(PAR);

  fprintf('\nSubmitted job %i\n\n', length(JOB_INFO));
end