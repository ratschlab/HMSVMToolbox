function [state_model, A, a_trans] = complete_model(state_model, PAR, transition_scores)

% function [state_model, A, a_trans] = complete_model(state_model, PAR, transition_scores)
%
% Checks the user-specified state-transition model completing
% fields which were not specified.

% written by Georg Zeller, MPI Tuebingen, Germany

%%% define state names and corresponding state ids
STATES = get_state_set(PAR);

% initialize names and ids in state_model struct
fn = fieldnames(STATES);
for i=1:length(fn),
  state_model(i).id = i;
  state_model(i).name = fn{i};
end

% by default define all transition scores as learning parameters
if ~isfield(STATES, 'trans_scores'),
  for i=1:length(state_model),
    state_model(i).trans_scores = ones(1, ...
                                       length(state_model(i).successors));
  end
end
for i=1:length(state_model),
  assert(length(state_model(i).trans_scores) ...
         == length(state_model(i).successors));
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


% by default learn all scoring function parameters
if ~isfield(state_model, 'learn_scores'),
  for i=1:length(state_model),
    state_model(i).learn_scores = ones(1,PAR.num_features);
  end
end

% by default learn independent scoring functions, one for each
% state-feature pair
if ~isfield(state_model, 'feature_scores'),
  for i=1:length(state_model),
    state_model(i).feature_scores ...
        = [find(state_model(i).learn_scores), i];
  end
end

for i=1:length(state_model),
  assert(size(state_model(i).feature_scores,1) ...
         == sum(state_model(i).learn_scores));
end

% by default do not enforce monotonic scoring functions
if ~isfield(state_model, 'monot_scores'),
  for i=1:length(state_model),
    state_model(i).monot_scores ...
        = ones(1, sum(state_model(i).learn_scores==1));
  end
end
for i=1:length(state_model),
  assert(size(state_model(i).feature_scores,1) ...
         == sum(state_model(i).learn_scores));
end

% by default do not couple any score functions together
if ~isfield(state_model, 'score_coupling'),
  for i=1:length(state_model),
    state_model(i).score_coupling ...
        = zeros(sum(state_model(i).learn_scores),2);
  end
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

