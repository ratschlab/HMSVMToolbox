function data_file = prepare_data()

% data_file = prepare_data()
%
% Prepares the data for label sequence learning with HM-SVM.
%
% Written by Georg Zeller, MPI Tuebingen, Germany, 2008

NORMALIZE_SIGNAL = 1

base_dir = '~/svn/projects/hmsvm/data/';
load([base_dir 'DATA']);
feature_idx = [7 8 10 12 14 15 21 22];
signal = DATA(feature_idx,:);

load([base_dir 'ANNOT']);
exm_id = ANNOT';

load([base_dir 'LABEL']);
label = LABEL';

% so far these are just dummies
subset_id = ones(size(label));
pos_id    = zeros(size(label));

if NORMALIZE_SIGNAL,
  % normalize
  exms = unique(exm_id);
  for i=1:length(exms),
    idx = find(exm_id == exms(i));
    for j=1:size(signal,1),
      signal(j,idx) = (signal(j,idx)-mean(signal(j,idx)))/std(signal(j,idx));
    end
  end
end

base_dir = '/fml/ag-raetsch/share/projects/enhancer/data/';
data_file = [base_dir 'hmsvm_data.mat'];
save(data_file, 'pos_id', 'label', 'signal', 'exm_id', 'subset_id');