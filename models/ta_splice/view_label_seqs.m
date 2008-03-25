function fh = view_label_seqs(fh, obs_seq, true_label_seq, pred_label_seq, second_label_seq)
% fh = view_label_seqs(fh, obs_seq, true_label_seq, [pred_label_seq], [second_label_seq])

% written by Georg Zeller, MPI Tuebingen, Germany

LABELS = get_label_set();
  
if nargin<3, error('at least 3 arguments expected'); end

figure(fh)
clf
hold on
c = colormap;
c = c(round(linspace(1,64,size(obs_seq,1))),:);
for i=1:size(obs_seq,1),
  plot(obs_seq(i,:), '.-', 'Color', c(i,:));
end
truth = -ones(size(true_label_seq(1,:)));
pos_idx = find(true_label_seq==LABELS.exonic);
truth(pos_idx) = 1;
neg_idx = find(true_label_seq(1,:)==LABELS.intronic ...
               | true_label_seq(1,:)==LABELS.intergenic);
truth(neg_idx) = 0;
idx = union(pos_idx, neg_idx);
plot(idx, truth(idx)+0.2, 'go-');

if exist('pred_label_seq', 'var'),
  pred = -ones(size(pred_label_seq(1,:)));
  pos_idx = find(pred_label_seq(1,:)==LABELS.exonic);
  pred(pos_idx) = 1;    
  neg_idx = find(pred_label_seq(1,:)==LABELS.intronic ...
                 | true_label_seq(1,:)==LABELS.intergenic);
  pred(neg_idx) = 0;
  idx = union(pos_idx, neg_idx);
  plot(idx, pred(idx)+0.2, 'r+-');
end

if exist('second_label_seq', 'var'),
  pred = -ones(size(second_label_seq(1,:)));
  pos_idx = find(second_label_seq(1,:)==LABELS.exonic);
  pred(pos_idx) = 1;    
  neg_idx = find(second_label_seq(1,:)==LABELS.intronic ...
                 | true_label_seq(1,:)==LABELS.intergenic);
  pred(neg_idx) = 0;
  idx = union(pos_idx, neg_idx);
  plot(idx, pred(idx)+0.2, 'c+-');
end

%axis([0, length(truth)+1 -10 10]);
      
