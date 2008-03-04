function [transition_scores, score_plifs] = res_to_scores(res, state_model, res_map, score_plifs, PAR)
% [transition_scores, score_plifs] = res_to_scores(res, state_model, res_map, score_plifs, PAR)

assert(PAR.num_features == size(score_plifs,1));
assert(length(state_model) == size(score_plifs,2));
assert(PAR.num_features == size(res_map,1));
assert(length(state_model) == size(res_map,2));

transition_scores = res(1:PAR.num_trans_score);

% extract new feature scoring function values from the solution vector
% (this is only done if specified as learning parameters in make_model.m)
for i=1:size(res_map,1), % for all features
  for j=1:size(res_map,2), % for all states
    if res_map(i,j) ~= 0,
      idx = res_map(i,j):res_map(i,j)+PAR.num_plif_nodes-1; 
      score_plifs(i,j).scores = res(idx)';
    end
  end
end
