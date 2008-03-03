function w = weights_to_vector(transition_weights, plif_weights, state_model, PAR)
% w = weights_to_vector(transition_weights, plif_weights, state_model, PAR)

num_features = PAR.num_features;
assert(num_features == size(plif_weights,1));
num_states = length(state_model);
assert(num_states == size(plif_weights,2));

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
for i=1:length(state_model), % for all states
  sc_idx = state_model(i).feature_scores;
  if ~isempty(sc_idx),
    for j=1:size(sc_idx,1),
      f = sc_idx(j,1);
      s = sc_idx(j,2);
      idx = (PAR.num_trans_score ...
             + (s-1)*PAR.num_features*PAR.num_plif_nodes ...
             + (f-1)*PAR.num_plif_nodes) ...
            + (1:PAR.num_plif_nodes);
      
      w(idx) = w(idx) + squeeze(plif_weights(j,i,:))';
    end
  end
end
assert(length(w) == PAR.num_param);
