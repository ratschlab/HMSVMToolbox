function [transitions, a_trans, A] = make_model(transition_scores)
% function [transitions, a_trans, A] = make_model(transition_scores)
% definition of the state-transition model

% states
STATES = get_state_set();
num_states = STATES.num;

if ~exist('transition_scores', 'var')
  transition_scores = zeros(1,num_states.^2);
end

% transition matrix
transitions = [];
A = -inf(num_states, num_states);
q = 0;

q = q + 1; 
A(STATES.positive, STATES.positive) = transition_scores(q);
transitions(end+1,:) = [STATES.positive, STATES.positive, q];

q = q + 1; 
A(STATES.negative, STATES.negative) = transition_scores(q);
transitions(end+1,:) = [STATES.negative, STATES.negative, q];

q = q + 1; 
A(STATES.positive, STATES.negative) = transition_scores(q);
transitions(end+1,:) = [STATES.positive, STATES.negative, q];

q = q + 1; 
A(STATES.negative, STATES.positive) = transition_scores(q);
transitions(end+1,:) = [STATES.negative, STATES.positive, q];


% transition start -> pos/neg
% with fixed transition score
A(STATES.start, STATES.negative) = 0;
A(STATES.start, STATES.positive) = 0;

% transition pos/neg -> stop
% with fixed transition score
A(STATES.negative, STATES.stop) = 0;
A(STATES.positive, STATES.stop) = 0;


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

