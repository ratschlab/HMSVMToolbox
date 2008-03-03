function [transition_scores, score_plifs] = res_to_scores(res, state_model, score_plifs, PAR)
% [transition_scores, score_plifs] = res_to_scores(res, state_model, score_plifs, PAR)

assert(PAR.num_features == size(score_plifs,1));
assert(length(state_model) == size(score_plifs,2));

transition_scores = res(1:PAR.num_trans_score);

% extract new feature scoring function values from the solution vector
% (this is only done if specified as learning parameters in make_model.m)
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
      
      score_plifs(j,i).scores = res(idx)';
    end
  else
    for j=1:size(score_plifs,1), % for all features
      assert(all(score_plifs(j,i).scores==0));
    end
  end
end
