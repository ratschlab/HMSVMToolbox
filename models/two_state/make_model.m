function [state_model, A, a_trans] = make_model(PAR, transition_scores)
% function [state_model, A, a_trans] = make_model(PAR, transition_scores)
% definition of the state-transition model

% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

%%% define state names and corresponding state ids
STATES = get_state_set();

% initialize names and ids in state_model struct
fn = fieldnames(STATES);
for i=1:length(fn),
  state_model(i).id = i;
  state_model(i).name = fn{i};
end


%%% associate a label with each state
LABELS = get_label_set();
state_model(STATES.start).label    = LABELS.negative;
state_model(STATES.stop).label     = LABELS.negative;
state_model(STATES.negative).label = LABELS.negative;
state_model(STATES.positive).label = LABELS.positive;


%%% define allowed transitions
% successors contains all ids of states reachable via an arc from this state
% trans_scores indicates whether a transition score will be learned (if 1)
% or whether transition score will be fixed to 0 (if 0).
% 1s are later replaced by an index into transition_scores.
state_model(STATES.stop).successors = [];
state_model(STATES.stop).trans_scores = [];
state_model(STATES.start).successors ...
    = [STATES.negative STATES.positive];
state_model(STATES.start).trans_scores = [0 0];
state_model(STATES.negative).successors ...
    = [STATES.negative STATES.positive STATES.stop];
state_model(STATES.negative).trans_scores = [1 1 0];
state_model(STATES.positive).successors ...
    = [STATES.positive STATES.negative STATES.stop];
state_model(STATES.positive).trans_scores = [1 1 0];

% initialize transition matrices and mapping to transition scores
if ~exist('transition_scores', 'var')
  transition_scores = zeros(1,length(state_model).^2);
end
A = -inf(length(state_model));
q = 1;
for i=1:length(state_model),
  assert(length(state_model(i).successors) ...
         == length(state_model(i).trans_scores));
  A(i, state_model(i).successors) = 0;
  idx_1 = find(state_model(i).trans_scores~=0);
  idx_2 = state_model(i).successors(idx_1);
  for j=1:length(idx_1),
    % assign score indices
    state_model(i).trans_scores(idx_1(j)) = q;
    A(i, idx_2(j)) = transition_scores(q);
    q = q + 1;
  end
end

% convert transition matrix to shogun format (a_trans)
a_trans = zeros(3,sum(~isinf(A(:))));
k = 0;
for i=1:size(A,1),
  idx = find(~isinf(A(i,:)));
  val = A(i,idx);
  a_trans(1, k+1:k+length(idx)) = i-1;
  a_trans(2, k+1:k+length(idx)) = idx-1;
  a_trans(3, k+1:k+length(idx)) = val;
  k = k + length(idx);
end
a_trans = a_trans';
[tmp, idx] = sort(a_trans(:,2));
a_trans = a_trans(idx,:);

%%% specify whether feature scoring functions are learned
%%% for a particular state, second column has to be equal to state_id
state_model(STATES.start).feature_scores    = [];
state_model(STATES.stop).feature_scores     = [];
score_cnt = 1;
state_model(STATES.negative).feature_scores = [[1:PAR.num_features]', ...
                    score_cnt*ones(PAR.num_features,1)];
score_cnt = score_cnt + 1;
state_model(STATES.positive).feature_scores = [[1:PAR.num_features]', ...
                    score_cnt*ones(PAR.num_features,1)];

%%% specify whether feature scoring functions will be coupled via
%%% regularization terms to those of other states
state_model(STATES.start).score_coupling    = [];
state_model(STATES.stop).score_coupling     = [];
state_model(STATES.negative).score_coupling = [];
state_model(STATES.positive).score_coupling = [];
