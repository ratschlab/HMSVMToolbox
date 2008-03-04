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
%%% expected is a 0/1 vector with nonzero entries for the features to be
%%% scored by functions included in the learning process
%state_model(STATES.start).learn_scores     = ones(PAR.num_features,1);
%state_model(STATES.stop).learn_scores      = ones(PAR.num_features,1);
% proxy scoring function test / score coupling test 
state_model(STATES.start).learn_scores     = ones(PAR.num_features,1);
state_model(STATES.stop).learn_scores      = ones(PAR.num_features,1);
state_model(STATES.negative).learn_scores  = ones(PAR.num_features,1);
state_model(STATES.positive).learn_scores  = ones(PAR.num_features,1);

%%% specify whether scoring functions should be shared between several
%%% states as a matrix 2 x k, where k is equal to the number of nonzeros
%%% in learn_scores of the same state
%%% first column is a feature index and second column indicates the state
%%% id  to which the scoring parameters correspond
state_model(STATES.start).feature_scores ...
    = [[1:PAR.num_features]', STATES.start*ones(PAR.num_features,1)];
state_model(STATES.stop).feature_scores ...
    = [[1:PAR.num_features]', STATES.stop*ones(PAR.num_features,1)];
% proxy scoring function test
%    = [[1:PAR.num_features]', STATES.start*ones(PAR.num_features,1)];
state_model(STATES.negative).feature_scores ...
    = [[1:PAR.num_features]', STATES.negative*ones(PAR.num_features,1)];
% proxy scoring function test
%    = [[1:PAR.num_features]', STATES.start*ones(PAR.num_features,1)];
state_model(STATES.positive).feature_scores ...
    = [[1:PAR.num_features]', STATES.positive*ones(PAR.num_features,1)];

for i=1:length(state_model),
  assert(size(state_model(i).feature_scores,1) ...
         == sum(state_model(i).learn_scores));
end

%%% specify whether feature scoring functions will be coupled via
%%% regularization terms to those of other states as a 2 x k matrix where
%%% k is equal to the number of nonzeros in learn_scores of the same state. 
%%% first column is a feature index and second column indicates the state
%%% id  to which the scoring parameters correspond (both should be zero
%%% if no coupling is desired)
%%% AVOID TO COUPLE the same pair of states twice as (i,j) and (j,i).
%%% only feature scoring functions which are not identified with others
%%% can be coupled
state_model(STATES.start).score_coupling ...
    = [[1:PAR.num_features]', STATES.negative*ones(PAR.num_features,1)];
%    = zeros(sum(state_model(STATES.start).learn_scores),2);
% coupling test
state_model(STATES.stop).score_coupling ...
    = [[1:PAR.num_features]', STATES.negative*ones(PAR.num_features,1)];
%    = zeros(sum(state_model(STATES.stop).learn_scores),2);
% coupling test
state_model(STATES.negative).score_coupling ...
    = zeros(sum(state_model(STATES.negative).learn_scores),2);
state_model(STATES.positive).score_coupling ...
    = zeros(sum(state_model(STATES.positive).learn_scores),2);

for i=1:length(state_model),
  assert(all(size(state_model(i).score_coupling) ...
             == size(state_model(i).feature_scores)));
  for j=1:size(state_model(i).score_coupling,1),
    f_idx = state_model(i).score_coupling(j,1);
    s_idx = state_model(i).score_coupling(j,2);
    if f_idx ~= 0,
      assert(s_idx ~= 0);
      assert(state_model(s_idx).feature_scores(j,1) == f_idx);
      assert(state_model(s_idx).feature_scores(j,2) == s_idx);
    end
  end
end
