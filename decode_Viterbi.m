function [pred_path true_path pred_path_mmv] = decode_Viterbi(obs_seq, transition_scores, score_plifs, PAR, true_label_seq)
% [pred_path true_path pred_path_mmv] 
% = decode_Viterbi(obs_seq, transition_scores, score_plifs, PAR, true_label_seq)
% calls shogun viterbi to decode i) the best path under current
% parameters (pred_path) and the maximal margin violator (pred_path_mmv)

% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

STATES = eval(sprintf('%s();', ...
                      PAR.model_config.func_get_state_set));
[transitions, a_trans, A] = eval(sprintf('%s(transition_scores);', ...
                                      PAR.model_config.func_make_model));

%%%%% Viterbi decoding to obtain best prediction WITHOUT loss

% compute score matrix for decoding
score_matrix = compute_score_matrix(obs_seq, score_plifs);
p = -inf(1, STATES.num);
p(STATES.start) = 0;
q = -inf(1, STATES.num);
q(STATES.stop) = 0;

[pred_path.score, state_seq] = sg('best_path_trans_simple', p, q, a_trans, score_matrix, 1);
pred_state_seq = state_seq + 1; % conversion from C to matlab inidices
pred_path.state_seq = pred_state_seq;
pred_path.label_seq = eval(sprintf('%s(pred_state_seq, STATES);', ...
                                   PAR.model_config.func_states_to_labels));

%%%% if true_state_seq is given (for training examples),
%%%% also used transitions and plif weights are computed
%%%% for the true path, pred_path is augmented with a loss
%%%% and a struct pred_path_mmv is returned corresponding 
%%%% to the maximal margin violator under the given loss

if exist('true_label_seq', 'var'),
  assert(length(true_label_seq)==size(obs_seq,2));

  %%%%% transition and plif weights for the true path 
  true_path.state_seq = eval(sprintf('%s(true_label_seq, STATES, obs_seq);', ...
                                     PAR.model_config.func_labels_to_states));
  true_path.label_seq = true_label_seq;
  [true_path.transition_weights, true_path.plif_weights] ...
      = path_weights(true_path.state_seq, obs_seq, transitions, score_plifs, STATES);

  % position-wise loss of the decoded state sequence
  loss = eval(sprintf('%s(true_path.state_seq, STATES);', ...
                      PAR.model_config.func_calc_loss_matrix));
  pred_loss = zeros(size(pred_state_seq));
  for i=1:size(pred_state_seq,2),
    pred_loss(i) = loss(pred_state_seq(i), i);
  end
  pred_path.loss = pred_loss;
  [pred_path.transition_weights, pred_path.plif_weights] ...
      = path_weights(pred_state_seq, obs_seq, transitions, score_plifs, STATES);
  
  %%%%% Viterbi decoding to obtain best prediction WITH loss, 
  %%%%% i.e. the maximal margin violater (MMV)
  
  % add loss to score matrix
  score_matrix = score_matrix + loss;
  
  [pred_path_mmv.score, state_seq] = sg('best_path_trans_simple', p, q, a_trans, score_matrix, 1);
  pred_state_seq = state_seq + 1; % conversion from C to matlab inidices
  pred_path_mmv.state_seq = pred_state_seq;
  pred_path_mmv.label_seq = eval(sprintf('%s(pred_state_seq, STATES);', ...
                                         PAR.model_config.func_states_to_labels));
  
  % position-wise loss of the decoded state sequence
  pred_loss = zeros(1, size(obs_seq,2));
  for i=1:size(obs_seq,2),
    pred_loss(i) = loss(pred_state_seq(i), i);
  end
  pred_path_mmv.loss = pred_loss;
  pred_path_mmv.score = pred_path_mmv.score - sum(pred_loss);
  
  [pred_path_mmv.transition_weights, pred_path_mmv.plif_weights] ...
      = path_weights(pred_state_seq, obs_seq, transitions, score_plifs, STATES);
end