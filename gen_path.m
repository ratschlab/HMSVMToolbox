function RET = gen_path(ARGS)

% RET = gen_path(ARGS)
%
% Viterbi decoding
%
% written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany, 2009

RET = struct;
if ~isfield(ARGS, 'start_idx'),
  ARGS.start_idx = [1, length(ARGS.true_label_seq)];
end
for i=1:size(ARGS.start_idx,1),
  idx = ARGS.start_idx(i,1):ARGS.start_idx(i,2);
  [pred_path true_path pred_path_mmv] ...
      = decode_Viterbi(ARGS.obs_seq(:,idx), ARGS.transition_scores, ARGS.score_plifs, ...
                       ARGS.PAR, ARGS.true_label_seq(idx), ARGS.true_state_seq(idx));
  
  if ARGS.PAR.extra_checks,
    w = weights_to_vector(pred_path.transition_weights, ...
                          pred_path.plif_weights, ARGS.state_model, ...
                          ARGS.res_map, ARGS.PAR);
    assert(abs(w*ARGS.res(1:ARGS.PAR.num_param) - pred_path.score) < ARGS.PAR.epsilon);
    
    w = weights_to_vector(pred_path_mmv.transition_weights, ...
                          pred_path_mmv.plif_weights, ARGS.state_model, ...
                          ARGS.res_map, ARGS.PAR);
    assert(abs(w*ARGS.res(1:ARGS.PAR.num_param) - pred_path_mmv.score) < ARGS.PAR.epsilon);
  end
  
  w_p = weights_to_vector(true_path.transition_weights, ...
                          true_path.plif_weights, ARGS.state_model, ...
                          ARGS.res_map, ARGS.PAR);
  w_n = weights_to_vector(pred_path_mmv.transition_weights, ...
                          pred_path_mmv.plif_weights, ARGS.state_model, ...
                          ARGS.res_map, ARGS.PAR);
  % returned values
  RET(i).pred_path = pred_path;
  RET(i).true_path = true_path;
  RET(i).pred_path_mmv = pred_path_mmv;
  RET(i).w_p = w_p;
  RET(i).w_n = w_n;
end

% eof