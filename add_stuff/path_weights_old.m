function [transition_weights, plif_weights] = path_weights_old(state_seq, obs_seq, score_plifs, state_model)

% [transition_weights, plif_weights] ...
%   = path_weights(state_seq, obs_seq, score_plifs, state_model)
%
% Counts how often indicidual transitions/supporting points of feature
% scoring functions are used by the given state sequence.
%
% state_seq -- sequence of states for which weights are computed
% obs_seq -- sequence of observations, i.e. the feature matrix
% score_plifs -- a struct representation of feature scoring functions
%   (see also score_plif_struct.h / .cpp)
% state_model -- graphical model specifying states and allowed
%   transitions between them
% returns weights of transitions, i.e. counts of how often
%   a certain transition has been used for decoding (transition_weights)
%   and weights of supporting points of the feature scoring functions
%   indicating how often certain scores are used (plif_weights)
%
% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany, 2008

transition_weights = zeros(length(state_model));
for i=1:length(state_seq)-1,
  transition_weights(state_seq(i), state_seq(i+1)) ...
      = transition_weights(state_seq(i), state_seq(i+1))+1;
end

num_plif_nodes = length(score_plifs(1,1).scores);
plif_weights = zeros(size(obs_seq,1), length(state_model), num_plif_nodes);
for f=1:size(obs_seq,1), % for all features
  for i=1:size(obs_seq,2), % for all observation positions
    v = plif_weights(f,state_seq(i),:);
    v = add_frac_vec(v, obs_seq(f,i), score_plifs(f,state_seq(i)).limits);
    plif_weights(f,state_seq(i),:) = v;
  end
end

% eof

