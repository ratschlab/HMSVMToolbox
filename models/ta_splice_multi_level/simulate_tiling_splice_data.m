function data_file = simulate_tiling_splice_data()

% data_file = simulate_tiling_splice_data()
%
% Simulates RNA transcript tiling array data together with predicted
% splice site information.
%
% Written by Georg Zeller, MPI Tuebingen, Germany

VERBOSE = 1;

LABEL = get_label_set();

num_exm = 500;              % number of examples
min_exm_len = 1000;         % min length of example sequences
intergenic_boundary = 500;  % min length of intergenic regions around genes

num_exons = [1 10];         % min and max number of exons blocks
exon_len  = [100 500];      % min and max exon length
intron_len  = [50 250];     % min and max intron length
probe_len = 25;             % oligonucleotide probe length
probe_spacing = 35;         % average spacing between subsequent probes
probe_offcenter_std = 3;    % standard deviation for probe offset from
                            % window center

intergenic_mean_I =  5;     % mean intensity of intergenic probes
intergenic_std_I  =  1;     % standard deviation of intensity of intergenic probes
intronic_mean_I   =  5;     % mean intensity of intronic probes
intronic_std_I    =  1;     % standard deviation of intensity of intronic probes
exonic_max_I      = 10;     % max intensity of exonic probes
exonic_std_I      =  1;     % standard deviation of intensity of exonic probes
num_expr_levels   = 10;     % number of discrete expression levels
ambiguous_std_I   =  2;     % standard deviation of intensities of
                            %   probes with ambiguous mapping

prop_outliers     = 0.0;    % proportion of outlier probes

ss_true_mean_score = 0.7;   % mean score of true splice sites   
ss_true_std_score  = 0.15;  % score standard deviation of true splice sites   
ss_decoy_mean_score = 0.3;  % mean score of decoy splice sites   
ss_decoy_std_score = 0.15;  % score standard deviation of decoy splice sites   
prop_ss_decoys = 19;        % proportion of decoy splice sites 

num_subsets = 5;            % number of subsets for crossvalidation

RESCALE_I = 1;              % if true, intensities are rescaled to [0, 1];

exon_level_mean_I = linspace(intronic_mean_I, exonic_max_I, ...
                             num_expr_levels);

exm_id = [];
pos_id = [];
label  = [];
subset_id = [];
don_pos   = [];  acc_pos   = [];
don_score = [];  acc_score = [];
don_label = [];  acc_label = [];
probe_signal = [];

for i=1:num_exm,
  % generate random gene model
  % for simplicity only generate genes on + strand
  num_exo = num_exons(1) + ceil((num_exons(2)-num_exons(1)).*rand(1)) - 1;
  exo_lens = exon_len(1) + ceil((exon_len(2)-exon_len(1)).*rand(1,num_exo)) - 1;
  ino_lens = intron_len(1) + ceil((intron_len(2)-intron_len(1)).*rand(1,num_exo-1)) - 1;
  
  gene_len = sum(exo_lens)+sum(ino_lens);
  gene_start = intergenic_boundary + 1;
  gene_stop = gene_start + gene_len - 1;
  
  exm_len = max(min_exm_len, gene_len + 2*intergenic_boundary);
  exons = [];
  introns = [];
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
  gene_level = ceil(num_expr_levels.*rand(1));
  
  % generate tiling
  num_probes = floor(exm_len/probe_spacing);
  probe_centers = probe_spacing.*(1:num_probes) - floor(probe_spacing/2);
  probe_pos = probe_centers + max([floor(probe_spacing/2)*ones(1,num_probes); ...
                                   round(probe_offcenter_std*randn(1,num_probes))]);

  % generate label for tiling probes
  hpl = floor(probe_len/2);
  exm_label = ones(size(probe_pos)) * LABEL.ambiguous;
  exm_label(probe_pos+hpl <= intergenic_boundary ...
              | probe_pos-hpl >= exm_len-intergenic_boundary+1) = LABEL.intergenic;
  for j=1:num_exo,
    exm_label(probe_pos-hpl >= exons(j,1) ...
                & probe_pos+hpl <= exons(j,2)) = LABEL.exonic;
  end
  for j=1:num_exo-1,
    exm_label(probe_pos-hpl >= introns(j,1) ...
                & probe_pos+hpl <= introns(j,2)) = LABEL.intronic;
  end
  
  label = [label exm_label];
  
  exm_id = [exm_id i*ones(1,num_probes)];
  pos_id = [pos_id 10^6*i + probe_pos];
  
  rs = ceil((num_subsets).*rand(1));
  subset_id = [subset_id rs*ones(1,num_probes)];

  keyboard

  % generate noisy splice site scores
  true_don_pos = exons(1:end-1,2)';
  true_acc_pos = exons(2:end,1)';
  num_true_ss = length(true_don_pos) + length(true_acc_pos);
  num_decoy_ss = 2 * round(num_true_ss/2 * prop_ss_decoys);
  decoy_ss_pos = randperm(exm_len);
  decoy_ss_pos = decoy_ss_pos(decoy_ss_pos(1:num_decoy_ss));
  
  true_don_score = ss_true_std_score * randn(size(true_don_pos)) + ss_true_mean_score; 
  true_acc_score = ss_true_std_score * randn(size(true_acc_pos)) + ss_true_mean_score; 
  decoy_ss_score = ss_decoy_std_score * randn(1,num_decoy_ss) + ss_decoy_mean_score; 
  
  don_pos_base = [true_don_pos decoy_ss_pos(1:num_decoy_ss/2)];
  acc_pos_base = [true_acc_pos decoy_ss_pos(num_decoy_ss/2+1:end)];
  don_score_base = [true_don_score decoy_ss_score(1:num_decoy_ss/2)];
  acc_score_base = [true_acc_score decoy_ss_score(num_decoy_ss/2+1:end)];
  don_score_base = max([don_score_base; zeros(size(don_score_base))]);
  don_score_base = min([don_score_base; ones(size(don_score_base))]);
  acc_score_base = max([acc_score_base; zeros(size(acc_score_base))]);
  acc_score_base = min([acc_score_base; ones(size(acc_score_base))]);
  
  don_label_base = [ones(size(true_don_pos)) -ones(1,num_decoy_ss/2)];
  [don_pos_base perm_idx] = sort(don_pos_base);
  don_score_base = don_score_base(perm_idx);
  don_label_base = don_label_base(perm_idx);
  
  acc_label_base = [ones(size(true_acc_pos)) -ones(1,num_decoy_ss/2)];
  [acc_pos_base perm_idx] = sort(acc_pos_base);
  acc_score_base = acc_score_base(perm_idx);
  acc_label_base = acc_label_base(perm_idx);
  
  % map splice site scores to tiling probe space
  for j=1:length(probe_pos)-1,
    don_idx = find(don_pos_base > probe_pos(j) & don_pos_base <= probe_pos(j+1));
    acc_idx = find(acc_pos_base > probe_pos(j) & acc_pos_base <= probe_pos(j+1));

    [max_don_score max_idx] = max(don_score_base(don_idx));
    if ~isempty(max_don_score),
      exm_don_score(j) = max_don_score;
      exm_don_pos(j)   = don_pos_base(don_idx(max_idx));
      exm_don_label(j) = don_label_base(don_idx(max_idx));
    else
      exm_don_score(j) = 0;
      exm_don_pos(j)   = round((probe_pos(j)+probe_pos(j+1))/2);
      exm_don_label(j) = 0;
    end
    [max_acc_score max_idx] = max(acc_score_base(acc_idx));
    if ~isempty(max_acc_score),
      exm_acc_score(j) = max_acc_score;
      exm_acc_pos(j)   = acc_pos_base(acc_idx(max_idx));
      exm_acc_label(j) = acc_label_base(acc_idx(max_idx));
    else
      exm_acc_score(j) = 0;
      exm_acc_pos(j)   = round((probe_pos(j)+probe_pos(j+1))/2);
      exm_acc_label(j) = 0;
    end
  end
  assert(length(exm_don_score)==length(exm_label)-1);
  assert(length(exm_don_pos)==length(exm_label)-1);
  assert(length(exm_don_label)==length(exm_label)-1);
  assert(length(exm_acc_score)==length(exm_label)-1);
  assert(length(exm_acc_pos)==length(exm_label)-1);
  assert(length(exm_acc_label)==length(exm_label)-1);

  don_score = [don_score exm_don_score];
  don_score = [don_score 0]; % to avoid frame shifts compared to label
  acc_score = [acc_score exm_acc_score];
  acc_score = [acc_score 0]; % to avoid frame shifts compared to label

  don_pos   = [don_pos   10^6*i + exm_don_pos];
  don_pos   = [don_pos   0]; % to avoid frame shifts compared to label
  acc_pos   = [acc_pos   10^6*i + exm_acc_pos];
  acc_pos   = [acc_pos   0]; % to avoid frame shifts compared to label

  don_label = [don_label exm_don_label];
  don_label = [don_label 0];
  acc_label = [acc_label exm_acc_label];
  acc_label = [acc_label 0];


  % generate noisy probe intensities by ...
  % i)  introducing label noise, i.e. outliers that are more similar
  %     to other label classes
  % ii) adding Gaussian noise to the intensity means
  exm_ps = mean([intergenic_mean_I; ...
                 intronic_mean_I; ...
                 exon_level_mean_I(gene_level); ...
                 exon_level_mean_I(gene_level)]) ...
           + ambiguous_std_I*randn(size(exm_label));

  distort = randperm(length(exm_label));
  distort = distort(1:round(length(exm_label)*prop_outliers));
  distorted_exm_label = exm_label;
  distorted_exm_label(intersect(distort, find(exm_label==LABEL.exonic))) = LABEL.intergenic;
  distorted_exm_label(intersect(distort, find(exm_label==LABEL.intronic ...
                            | exm_label==LABEL.intergenic))) = LABEL.exonic;

  ige_idx = find(distorted_exm_label==LABEL.intergenic);
  exm_ps(ige_idx) = intergenic_std_I*randn(size(ige_idx)) + intergenic_mean_I;
  ino_idx = find(distorted_exm_label==LABEL.intronic);
  exm_ps(ino_idx) = intronic_std_I*randn(size(ino_idx)) + intronic_mean_I;
  exo_idx = find(distorted_exm_label==LABEL.exonic);
  exm_ps(exo_idx) = exonic_std_I*randn(size(exo_idx)) + exon_level_mean_I(gene_level);

  assert(length(distorted_exm_label) == length(exm_label));
  assert(length(exm_ps) == length(exm_label));
  probe_signal = [probe_signal exm_ps];

  if VERBOSE>=2,
    figure(1);
    clf
    hold on
    for j=1:num_exo,
      fill([exons(j,1) exons(j,1) exons(j,2) exons(j,2)], [-0.5 -1.5 -1.5 -0.5], ...
           [0.8 0.8 0.8]);
      if j<num_exo,
        plot([introns(j,1) introns(j,2)], [-1 -1], '-k');
      end
    end
    don_idx = find(exm_don_label~=0);
    acc_idx = find(exm_acc_label~=0);
    plot(exm_don_pos(don_idx), exm_don_score(don_idx), '.-g');
    plot(exm_don_pos(don_idx), 0.5*exm_don_label(don_idx)+2, '+g');
    plot(exm_acc_pos(acc_idx), exm_acc_score(acc_idx), '.-b');
    plot(exm_acc_pos(acc_idx), 0.5*exm_acc_label(acc_idx)+2, '+b');
    axis([0 exm_len -2 5+0.2*exonic_max_I]);

    plot(probe_centers, 3+0.2*exm_ps, '.-r')
    plot(probe_centers(exo_idx), 3+0.2*exm_ps(exo_idx), 'or')
    plot(probe_centers(ino_idx), 3+0.2*exm_ps(ino_idx), 'dr')
    plot(probe_centers(ige_idx), 3+0.2*exm_ps(ige_idx), 'xr')
    text(probe_centers(exo_idx(1)), 3, sprintf('genelevel: %i', gene_level));
    keyboard
  end

  clear exm_don_score exm_don_pos exm_don_label max_don_score ...
      exm_acc_score exm_acc_pos exm_acc_label max_acc_score max_idx ...
      exm_label exm_ps
end


if RESCALE_I,
  mn = min(probe_signal);
  mx = max(probe_signal);
  probe_signal = (probe_signal-mn)/(mx-mn);
  assert(all(probe_signal>-0.001 & probe_signal<1.001));
end

% insert splice site score between probe scores
signal(1,1:2:2*length(probe_signal)-1) = probe_signal;
signal(2,2:2:2*length(don_score)) = don_score;
signal(3,2:2:2*length(acc_score)) = acc_score;
signal(4,2:2:2*length(don_score)) = max([don_score; acc_score]);

l = label;
label(1:2:2*length(l)-1) = l;
double_ss = find(don_label==1 & acc_label==1);
ss_l = LABEL.no_ss*ones(size(don_label));
ss_l(don_label==+1) = LABEL.ei_ss;
ss_l(acc_label==+1) = LABEL.ie_ss;
ss_l(double_ss) = LABEL.double_ss;
label(2:2:2*length(ss_l)) = ss_l;

p = pos_id;
pos_id(1:2:2*length(p)-1) = p;
ss_pos = round((acc_pos+don_pos)/2);
ss_pos(ss_l==LABEL.ei_ss) = don_pos(ss_l==LABEL.ei_ss);
ss_pos(ss_l==LABEL.ie_ss) = acc_pos(ss_l==LABEL.ie_ss);
pos_id(2:2:2*length(ss_pos)) = ss_pos;

s = subset_id;
subset_id(1:2:2*length(s)-1) = s;
subset_id(2:2:2*length(s)) = s;

e = exm_id;
exm_id(1:2:2*length(e)-1) = e;
exm_id(2:2:2*length(e)) = e;

% remove the last (splice) element from each sequence
% to have them start and end with hybridization elements
rm_idx = [];
for i=1:num_exm;
  idx = find(exm_id==i);
  rm_idx = [rm_idx idx(end)];
end
exm_id(rm_idx)    = [];
subset_id(rm_idx) = [];
pos_id(rm_idx)    = [];
assert(all(pos_id(1:end-1)<=pos_id(2:end)));
label(rm_idx)     = [];
signal(:,rm_idx)  = [];

assert(size(label,2) == size(signal,2));
assert(size(label,2) == size(pos_id,2));
assert(size(label,2) == size(exm_id,2));
assert(size(label,2) == size(subset_id,2));

base_dir = '/fml/ag-raetsch/share/projects/tiling_arrays/ta_splice_simulations/';
data_file = [base_dir 'ta_splice_data.mat'];
save(data_file, 'pos_id', 'label', 'signal', 'exm_id', 'subset_id');

if VERBOSE>=1,
  figure; view_label_seqs(gcf, signal(:,1:1000), label(1:1000));
  addpath ~/svn/projects/tiling_arrays/common
  [TP FP TN FN] = eval_separation(don_score, don_label);
  figure; plot_ROC(TP, FP, TN, FN);
  [TP FP TN FN] = eval_separation(acc_score, acc_label);
  figure; plot_ROC(TP, FP, TN, FN);
  keyboard
end

% eof