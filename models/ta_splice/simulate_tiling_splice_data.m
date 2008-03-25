function data_file = simulate_tiling_splice_data()


% written by Georg Zeller, MPI Tuebingen, Germany

base_dir = '~/svn/projects/hmsvm/data/';

LABEL = get_label_set();

num_exm = 100;             % number of examples
min_exm_len = 1000;        % min length of example sequences
intergenic_boundary = 500; % min length of intergenic regions around genes

num_exons = [0 10];        % min and max number of exons blocks
exon_len  = [25 500];      % min and max exon length
intron_len  = [25 250];    % min and max intron length
probe_len = 25;            % oligonucleotide probe length
probe_spacing = 35;        % average spacing between subsequent probes
probe_offcenter_std = 3;   % standard deviation for probe offset from
                           % window center

intergenic_mean_I =  6;    % mean intensity of intergenic probes
intergenic_std_I  =  1;    % standard deviation of intensity of intergenic probes
intronic_mean_I   =  6;    % mean intensity of intronic probes
intronic_std_I    =  1;    % standard deviation of intensity of intronic probes
exonic_mean_I     = 10;    % mean intensity of exonic probes
intronic_std_I    =  2;    % standard deviation of intensity of exonic probes
num_exon_levels   = 10;    % number of discrete expression levels
ambiguous_std_I   =  3;    % standard deviation of intensities of
                           % probes with ambigous mapping

prop_outliers     = 0.2;   % proportion of outlier probes

ss_true_mean_score = 0.7;  % mean score of true splice sites   
ss_true_std_score  = 0.2;  % score standard deviation of true splice sites   
ss_decoy_mean_score = 0.3; % mean score of decoy splice sites   
ss_decoy_std_score = 0.2;  % score standard deviation of decoy splice sites   
prop_ss_decoys = 19;       % proportion of decoy splice sites 

num_subsets = 5;           % number of subsets for crossvalidation


exon_level_mean_I = linspace(intronic_mean_I, ...
                             2*exonic_mean_I-intronic_mean_I, ...
                             num_exon_levels);

exm_id = [];
pos_id = [];
label = [];
subset_id = [];
splice_pos = [];
splice_score = [];
for i=1:num_exm,
  % generate random gene model
  num_exo = num_exons(1) + ceil((num_exons(2)-num_exons(1)).*rand(1)) - 1;
  exo_lens = exon_len(1) + ceil((exon_len(2)-exon_len(1)).*rand(1,num_exo)) - 1;
  ino_lens = intron_len(1) + ceil((intron_len(2)-intron_len(1)).*rand(1,num_exo-1)) - 1;
  
  gene_len = sum(exo_lens)+sum(ino_lens);
  gene_start = intergenic_boundary + 1;
  gene_stop = gene_start + gene_len - 1;
  
  exm_len  = max(min_exm_len, gene_len + 2*intergenic_boundary);
  
  b = intergenic_boundary + 1;
  for j=1:num_exo,
    e = b + exo_lens(j) - 1;
    exons(j,:) = [b, e];
    if j<num_exo,
      b = e + ino_lens(j) + 1;
      introns(j,:) = [e+1, b-1];
    end
  end
  assert(b - 1 <= gene_stop);
  assert(b - 1 + intergenic_boundary <= exm_len);
  gene_level = ceil(num_exon_levels.*rand(1));
  
  % generate tiling
  num_probes = floor(exm_len/probe_spacing);
  probe_centers = probe_spacing.*(1:num_probes) - floor(probe_sacing/2);
  probe_pos = probe_centers + max([floor(probe_spacing/2)*ones(1,num_probes); ...
                                   round(probe_offcenter_std*randn(1,num_probes))]);

  % generate label for tiling probes
  hpl = floor(probe_len/2);
  l = ones(size(probe_pos)) * LABEL.ambigous;
  l(probe_pos+hpl <= intergenic_boundary ...
              | probe_pos-hpl >= exm_len-intergenic_boundary+1) = LABEL.intergenic;
  for j=1:num_exo,
    l(probe_pos-hpl >= exons(j,1) ...
                & probe_pos+hpl <= exons(j,2)) = LABEL.exonic;
  end
  for j=1:num_exo-1,
    l(probe_pos-hpl >= introns(j,1) ...
                & probe_pos+hpl <= introns(j,2)) = LABEL.intronic;
  end
  
  label = [label l];
  
  exm_id = [exm_id i*ones(1,num_probes)];
  pos_id = [exm_id 10^6*i + probe_pos];
  
  rs = ceil((num_subsets).*rand(1));
  subset_id = [subset_id rs*ones(1,num_probes)];


  % generate noisy splice site scores
  true_ss_pos  = [exons(2:end,1)' exons(1:end-1,2)'];
  num_true_ss = length(true_ss_pos);
  num_decoy_ss = round(num_true_ss * prop_ss_decoys)
  decoy_ss_pos = randperm(exm_len);
  decoy_ss_pos = decoy_ss_pos(decoy_ss_pos(1:num_ss_decoys));
  
  true_ss_score = ss_true_std_score * randn(1,num_true_ss) + ss_true_mean_score; 
  decoy_ss_score = ss_decoy_std_score * randn(1,num_decoy_ss) + ss_deccoy_mean_score; 
  
  ss_pos = [true_ss_pos decoy_ss_pos];
  ss_score = [true_ss_score decoy_ss_score];
  ss_score = max([ss_score; zeros(size(ss_score))]);
  ss_score = min([ss_score; ones(size(ss_score))]);
  
  ss_label = [ones(size(true_ss_pos)) -ones(size(decoy_ss_pos))];
  [ss_pos perm_idx] = sort(ss_pos);
  ss_score = ss_score(perm_idx);
  ss_label = ss_label(perm_idx);
  
  % map splice site scores to tiling probe space
  for j=1:length(probe_pos),
    if j==1,
      idx = find(ss_pos < probe_pos(1));
    else
      idx = find(ss_pos > probe_pos(j-1) & ss_pos < probe_pos(j));
    end
    [max_ss_score max_pos] = max(ss_score(idx));
    exm_splice_score(i) = max_ss_score;
    exm_splice_pos(i) = ss_pos(idx(max_pos));
    exm_splice_label(i) = ss_label(idx(max_pos));
  end

  splice_score = [splice_score exm_splice_score];
  splice_pos   = [splice_pos   exm_splice_pos];
  splice_label = [splice_label exm_splice_label];
end

% generate noisy probe intensities by ...
% i)  introducing label noise, i.e. outliers that are more similar
%     to other label classes
% ii) adding Gaussian noise to the intensity means

signal = mean([intergenic_mean_I; ...
               intronic_mean_I; ...
               exon_level_mean_I(gene_level); ...
               exon_level_mean_I(gene_level)]) ...
         + ambiguous_std_I*randn(size(label));

distort = randperm(length(label));
distort = distort(1:round(length(label)*prop_outliers));
l = label;
l(intersect(distort, find(label==LABEL.exonic))) = LABEL.intergenic;
l(intersect(distort, find(label==LABEL.intronic ...
                          | label==LABEL.intergenic))) = LABEL.exonic;

ige_idx = find(l==LABEL.intergenic);
signal(ige_idx) = intergenic_std_I*randn(size(ige_idx)) + intergenic_mean_I;
ino_idx = find(l==LABEL.intronic);
signal(ino_idx) = intronic_std_I*randn(size(ino_idx)) + intronic_mean_I;
exo_idx = find(l==LABEL.exonic);
signal(exo_idx) = exonic_std_I*randn(size(exo_idx)) + exonic_mean_I;

signal(2,:) = splice_score;

base_dir = '/fml/ag-raetsch/share/projects/hmsvm_toydata/'
data_file = [base_dir 'ta_splice_data.mat'];
save(data_file, 'pos_id', 'label', 'signal', 'exm_id', 'subset_id', ...
     'splice_score', 'splice_pos', 'splice_label');

keyboard