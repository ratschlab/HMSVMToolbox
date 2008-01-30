function [A b Q f lb ub slacks res num_param] = init_QP(transition_scores, score_plifs, STATES, PAR)
% [A b Q f lb ub slacks res num_param] = init_QP(transition_scores, score_plifs, STATES, PAR)
% initialize QP

% written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany

res = transition_scores;
score_starts = [];
cnt = 1;
for f=1:size(score_plifs,1), % for all features
  for s=1:size(score_plifs,2), % for all states
    score_starts(cnt) = length(res)+1;
    res = [res score_plifs(f,s).scores]; 
    cnt = cnt + 1;
  end
end
score_starts(end+1) = length(res)+1;
num_param = length(res);

INF = 1e20;

A = [];
b = [];


%%%%% Regularizer

% regularizer to keep PLiF values small
Q = sparse(zeros(length(res) + PAR.num_exm));
Q(1:length(res),1:length(res)) = PAR.C_small*eye(length(res));

% generate smoothness terms
for i=1:length(score_starts)-1,
  idx = score_starts(i):score_starts(i+1)-1;
  for j=1:length(idx)-1,
    % C*x_k^2 - 2C*x_k*x_{k+1} + C*x_{k+1}^2 = C*(x_k - x_{k+1})^2
    Q(idx(j),  idx(j+1)) = Q(idx(j),  idx(j+1)) - PAR.C_smooth;
    Q(idx(j+1),idx(j))   = Q(idx(j+1),idx(j))   - PAR.C_smooth;
    
    Q(idx(j),  idx(j))   = Q(idx(j),  idx(j))   + PAR.C_smooth;
    Q(idx(j+1),idx(j+1)) = Q(idx(j+1),idx(j+1)) + PAR.C_smooth;
  end 
end

f = [zeros(1,length(res)) ones(1,PAR.num_exm)];
lb = [-INF*ones(1,length(res)) zeros(1,PAR.num_exm)];
ub = [INF*ones(1,length(res)) INF*ones(1,PAR.num_exm)];

slacks = zeros(1,PAR.num_exm);
res = [res slacks];
