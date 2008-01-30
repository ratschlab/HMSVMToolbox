function data_file = simulate_data()
% call like simulate_data()

base_dir = '~/svn/projects/hmsvm/data/';

num_exm = 50;
exm_len = 500;
num_features = 5;
block_len = [10,50];
num_blocks = [1, 5];
num_subsets = 5;

exm_id = [];
pos_id = [];
label = [];
subset_id = [];
for i=1:num_exm,
  exm_id = [exm_id i*ones(1,exm_len)];
  pos_id = [exm_id 1000*i + (1:exm_len)];
  % generate label sequence randomly
  % containing num_blocks(1) to num_blocks(2) blocks of positive labels
  % each of length between block_len(1) and block_len(2)
  l = -ones(1,exm_len);
  rnb = num_blocks(1) + ceil((num_blocks(2)-num_blocks(1)).*rand(1)) - 1;
  for j=1:rnb,
    rl = block_len(1) + ceil((block_len(2)-block_len(1)).*rand(1)) - 1;
    rp = ceil((exm_len-rl).*rand(1));
    l(rp:rp+rl) = 1;
  end
  label = [label l];
  rs = ceil((num_subsets).*rand(1));
  subset_id = [subset_id rs*ones(1,exm_len)];
end

% generate features by i) introducing label noise, i.e. flipping a
% proportion prop_distort of labels and ii) adding gaussian noise to the
% (distorted) label sequence
prop_distort = 0.2;
for i=1:num_features,
  distort = randperm(length(label));
  d1 = distort(1:round(length(label)*prop_distort));
  d2 = distort(end-round(length(label)*prop_distort)+1:end);
  l = label;
  l(d1) = l(d2);
  signal(i,:) = l+3*randn(size(label));
end

base_dir = '/fml/ag-raetsch/share/projects/enhancer/data/';
data_file = [base_dir 'hmsvm_data.mat'];
save(data_file, 'pos_id', 'label', 'signal', 'exm_id', 'subset_id');

