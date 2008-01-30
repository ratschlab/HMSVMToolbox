function [transition_weights, plif_weights] = path_weights(state_seq, obs_seq, transition_scores, score_plifs, STATES)
% [transition_weights, plif_weights] = path_weights(state_seq, obs_seq, transition_scores, score_plifs, STATES)
% count transitions/plif nodes used by decoded state sequence

% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

num_trans = zeros(STATES.num);
for i=1:length(state_seq)-1,
  num_trans(state_seq(i), state_seq(i+1)) ...
      = num_trans(state_seq(i), state_seq(i+1))+1;
end
for i=1:size(transition_scores,1),
  transition_weights(i) = num_trans(transition_scores(i,1), transition_scores(i,2));
end

num_plif_nodes = length(score_plifs(1,1).scores);
plif_weights = zeros(size(obs_seq,1), STATES.num, num_plif_nodes);
for f=1:size(obs_seq,1), % for all features
  for i=1:size(obs_seq,2), % for all observation positions
    plif_weights(f,state_seq(i),:) = add_frac_vec(plif_weights(f,state_seq(i),:), ...
                                                  obs_seq(f,i), ...
                                                  score_plifs(f,state_seq(i)).limits);
  end
end
