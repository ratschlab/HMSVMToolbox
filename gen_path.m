function RET = gen_path(ARGS)

% RET = gen_path(ARGS)
%
%
%
% written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany, 2009

% include user-specified include paths
for i=1:length(ARGS.PAR.include_paths),
  addpath(ARGS.PAR.include_paths{i});
end

%%% Viterbi decoding
[pred_path true_path pred_path_mmv] ...
    = decode_Viterbi(ARGS.obs_seq, ARGS.transition_scores, ARGS.score_plifs, ...
                     ARGS.PAR, ARGS.true_label_seq, ARGS.true_state_seq);

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
RET = struct;
RET.pred_path = pred_path;
RET.true_path = true_path;
RET.pred_path_mmv = pred_path_mmv;
RET.w_p = w_p;
RET.w_n = w_n;