function w = weights_to_vector(transition_weights, plif_weights, state_model, res_map, PAR)

% w = weights_to_vector(transition_weights, plif_weights, state_model, res_map, PAR)
%
% Reshapes the weights of individual feature scoring functions and
% transition weights into a vector (to be able to take the inner product
% with the parameter vector).
%
% Written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany, 2008

num_features = PAR.num_features;
assert(num_features == size(plif_weights,1));
assert(num_features == size(res_map,1));
num_states = length(state_model);
assert(num_states == size(plif_weights,2));
assert(num_states == size(res_map,2));

w = zeros(1, PAR.num_param);
for s=1:num_states,
  idx_1 = find(state_model(s).trans_scores~=0);
  idx_2 = state_model(s).successors(idx_1);
  idx_1 = state_model(s).trans_scores(idx_1);
  w(idx_1) = transition_weights(s,idx_2);  
end
assert(sum(w ~= 0) <= PAR.num_trans_score);

% extract weights from a structure corresponding to score_plifs
% to obtain the weights for parameters that learned (i.e. optimized)
% and assemble a w vector corresponding to res (the solution of the
% optimization problem)
for i=1:size(res_map,1), % for all features
  for j=1:size(res_map,2), % for all states
    if res_map(i,j) ~= 0,
      idx = res_map(i,j):res_map(i,j)+PAR.num_plif_nodes-1; 
      w(idx) = w(idx) + squeeze(plif_weights(i,j,:))';
    end
  end
end
assert(length(w) == PAR.num_param);
