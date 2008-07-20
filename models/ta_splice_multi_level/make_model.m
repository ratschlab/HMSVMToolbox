function [state_model, A, a_trans] = make_model(PAR, transition_scores)
% function [state_model, A, a_trans] = make_model(PAR, transition_scores)
% definition of the state-transition model

% written by Georg Zeller, MPI Tuebingen, Germany

%%% define state names and corresponding state ids
[STATES, NUM_LEVELS] = get_state_set();

% initialize names and ids in state_model struct
fn = fieldnames(STATES);
for i=1:length(fn),
  state_model(i).id = i;
  state_model(i).name = fn{i};
  state_model(i).is_start = 0;
  state_model(i).is_stop  = 0;
end
state_model(STATES.ige).is_start = 1;
state_model(STATES.ige).is_stop  = 1;


%%% associate a label with each state
LABELS = get_label_set();
state_model(STATES.ige).label    = LABELS.intergenic;
state_model(STATES.ige_ss).label = LABELS.no_ss;
exo_idx = strmatch('exo', fn);
assert(length(exo_idx) == NUM_LEVELS);
ino_idx = strmatch('ino', fn);
assert(length(ino_idx) == NUM_LEVELS);
e_ss_idx = strmatch('e_ss', fn);
assert(length(e_ss_idx) == NUM_LEVELS);
i_ss_idx = strmatch('i_ss', fn);
assert(length(i_ss_idx) == NUM_LEVELS);
ei_ss_idx = strmatch('ei_ss', fn);
assert(length(ei_ss_idx) == NUM_LEVELS);
ie_ss_idx = strmatch('ie_ss', fn);
assert(length(ie_ss_idx) == NUM_LEVELS);

for i=1:NUM_LEVELS, 
  state_model(exo_idx(i)).label   = LABELS.exonic;
  state_model(ino_idx(i)).label   = LABELS.intronic;
  state_model(e_ss_idx(i)).label  = LABELS.no_ss;
  state_model(i_ss_idx(i)).label  = LABELS.no_ss;
  state_model(ei_ss_idx(i)).label = LABELS.ei_ss;
  state_model(ie_ss_idx(i)).label = LABELS.ie_ss;
end


%%% define allowed transitions
% successors contains all ids of states reachable via an arc from this state
% trans_scores indicates whether a transition score will be learned (if 1)
% or whether transition score will be fixed to 0 (if 0).
% 1s are later replaced by an index into transition_scores.
state_model(STATES.ige).successors           = [STATES.ige_ss e_ss_idx'];
state_model(STATES.ige).trans_scores         = [1 ones(1,NUM_LEVELS)];
state_model(STATES.ige_ss).successors        = [STATES.ige];
state_model(STATES.ige_ss).trans_scores      = [0];
for i=1:NUM_LEVELS,
  state_model(exo_idx(i)).successors     = [e_ss_idx(i) ei_ss_idx(i)]; 
  state_model(exo_idx(i)).trans_scores   = [1 1];
  state_model(ino_idx(i)).successors     = [i_ss_idx(i) ie_ss_idx(i)];
  state_model(ino_idx(i)).trans_scores   = [1 1];
  state_model(e_ss_idx(i)).successors    = [STATES.ige exo_idx(i)];
  state_model(e_ss_idx(i)).trans_scores  = [0 0];
  state_model(i_ss_idx(i)).successors    = [ino_idx(i)];
  state_model(i_ss_idx(i)).trans_scores  = [0];
  state_model(ei_ss_idx(i)).successors   = [ino_idx(i)];
  state_model(ei_ss_idx(i)).trans_scores = [0];
  state_model(ie_ss_idx(i)).successors   = [exo_idx(i)];
  state_model(ie_ss_idx(i)).trans_scores = [0];
end
% transitions from level i to i+1 and vice versa
for i=1:NUM_LEVELS-1,
  state_model(ino_idx(i)).successors(end+1)     = i_ss_idx(i+1);
  state_model(ino_idx(i)).trans_scores(end+1)   = 1;
  state_model(ino_idx(i+1)).successors(end+1)   = i_ss_idx(i);
  state_model(ino_idx(i+1)).trans_scores(end+1) = 1;
end

for i=1:length(state_model),
  assert(length(state_model(i).successors) == ...
         length(state_model(i).trans_scores));
end


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
assert(PAR.num_features == 4);
state_model(STATES.ige).learn_scores     = [1 0 0 0]; % hyb intensity
state_model(STATES.ige_ss).learn_scores  = [0 0 0 1]; % max splice score
for i=1:NUM_LEVELS,
  state_model(exo_idx(i)).learn_scores   = [1 0 0 0]; % hyb intensity
  state_model(ino_idx(i)).learn_scores   = [1 0 0 0]; % hyb intensity
  state_model(e_ss_idx(i)).learn_scores  = [0 0 0 1]; % max splice score
  state_model(i_ss_idx(i)).learn_scores  = [0 0 0 1]; % max splice score
  state_model(ei_ss_idx(i)).learn_scores = [0 1 0 0]; % donor(+)/acceptor(-) splice score
  state_model(ie_ss_idx(i)).learn_scores = [0 0 1 0]; % acceptor(+)/donor(-) splice score
end


%%% specify whether scoring functions should be shared between several
%%% states as a matrix k x 2, where k is equal to the number of nonzeros
%%% in learn_scores of the same state
%%% first column is a feature index and second column indicates the state
%%% id  to which the scoring parameters correspond
for i=1:length(state_model),
  state_model(i).feature_scores ...
      = [find(state_model(i).learn_scores), i];
end

for i=1:length(state_model),
  assert(size(state_model(i).feature_scores,1) ...
         == sum(state_model(i).learn_scores));
end


%%% specify monotonicity constraints for feature scoring functions
%%% as a vector of length k containing +1 (monotonically increasing
%%% scoring function), -1 (monotonically decreasing) and 0 (no
%%% monotonicity desired) entries where k is equal to the
%%% number of nonzeros in learn_scores of the same state.
%%% will not be considered when scoring functions are shared with
%%% another states
state_model(STATES.ige).monot_scores     =  0;
state_model(STATES.ige_ss).monot_scores  = -1;
for i=1:NUM_LEVELS,
  state_model(exo_idx(i)).monot_scores   =  0;
  state_model(ino_idx(i)).monot_scores   =  0;
  state_model(e_ss_idx(i)).monot_scores  = -1;
  state_model(i_ss_idx(i)).monot_scores  = -1;
  state_model(ei_ss_idx(i)).monot_scores = +1;
  state_model(ie_ss_idx(i)).monot_scores = +1;
end

for i=1:length(state_model),
  assert(size(state_model(i).feature_scores,1) ...
         == sum(state_model(i).learn_scores));
end


%%% specify whether feature scoring functions will be coupled via
%%% regularization terms to those of other states as a k x 2 matrix where
%%% k is equal to the number of nonzeros in learn_scores of the same state. 
%%% first column is a feature index and second column indicates the state
%%% id to which the scoring parameters correspond (both should be zero
%%% if no coupling is desired)
%%% AVOID TO COUPLE the same pair of states twice as (i,j) and (j,i).
%%% only feature scoring functions which are not shared between states
%%% can be coupled
for i=1:length(state_model),
  state_model(i).score_coupling ...
      = zeros(sum(state_model(i).learn_scores),2);
end

for i=1:NUM_LEVELS-1,
  state_model(exo_idx(i)).score_coupling   = [1 exo_idx(i+1)]; 
  state_model(ino_idx(i)).score_coupling   = [1 ino_idx(i+1)];
  state_model(e_ss_idx(i)).score_coupling  = [4 e_ss_idx(i+1)];
  state_model(i_ss_idx(i)).score_coupling  = [4 i_ss_idx(i+1)];
  state_model(ei_ss_idx(i)).score_coupling = [2 ei_ss_idx(i+1)];
  state_model(ie_ss_idx(i)).score_coupling = [3 ie_ss_idx(i+1)];
end

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
    else
      assert(s_idx == 0);
    end
  end
end

keyboard

