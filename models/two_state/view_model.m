function fhs = view_model(STATES, score_plifs, transitions, transition_scores)
% fhs = view_model(STATES, score_plifs, transitions, transition_scores)
% plots the score plifs

fn = fieldnames(STATES);
fn(strmatch('num', fn, 'exact')) = [];
num_features = size(score_plifs,1);
for s=1:STATES.num,
  for t=1:num_features,
    scores(t,:) = score_plifs(t,s).scores;
    limits(t,:) = score_plifs(t,s).limits;
    feats(t,:) = repmat(t, size(score_plifs(t,s).limits));
  end
  figure
  plot3(limits', feats', scores', '.-');
  xlabel('signal');
  ylabel('feature');
  zlabel('score');
  title(fn(s));
  grid on
  fhs(s) = gcf;
  colors = colormap;
  colors = colors(round(linspace(1,64,num_features)),:);
  ch = get(gca, 'Children');
  assert(length(ch) == num_features);
  for c=1:length(ch),
    set(ch(c), 'Color', colors(c,:));
  end
end

figure
A = zeros(STATES.num);
for i=1:length(transition_scores),
  A(transitions(i,1), transitions(i,2)) = transition_scores(i);
end
imagesc(A);

% eof
