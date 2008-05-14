function [transition_weights, plif_weights] = path_weights(state_seq, obs_seq, score_plifs, state_model)

% [transition_weights, plif_weights] ...
%   = path_weights(state_seq, obs_seq, score_plifs, state_model)
%
% Counts how often indicidual transitions/plif nodes are used by given
% state sequence.
%
% Written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany, 2008

transition_weights = zeros(length(state_model));
for i=1:length(state_seq)-1,
  transition_weights(state_seq(i), state_seq(i+1)) ...
      = transition_weights(state_seq(i), state_seq(i+1))+1;
end

num_plif_nodes = length(score_plifs(1,1).scores);
plif_weights = zeros(size(obs_seq,1), length(state_model), num_plif_nodes);
for f=1:size(obs_seq,1), % for all features
  for i=1:size(obs_seq,2), % for all observation positions
    plif_weights(f,state_seq(i),:) = add_frac_vec(plif_weights(f,state_seq(i),:), ...
                                                  obs_seq(f,i), ...
                                                  score_plifs(f,state_seq(i)).limits);
  end
end
