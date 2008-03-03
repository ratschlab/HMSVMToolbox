function [A b f lb ub slacks res PAR] = init_LP(transition_scores, score_plifs, state_model, PAR)
% [A b f lb ub slacks res PAR] = init_LP(transition_scores, score_plifs, state_model, PAR)
% initialize LP

% written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany

%%% optimization paramaters: 
%%%   i) transition scores
res = transition_scores;
num_transition = length(res);

%   ii) y-values of PLiF supporting points (feature scoring functions)
score_starts = [];
cnt = 0;
for i=1:length(state_model), % for all states
  sc_idx = state_model(i).feature_scores;
  if ~isempty(sc_idx),
    assert(size(sc_idx,1) == PAR.num_features);
    for j=1:size(sc_idx,1),
      f = sc_idx(j,1);
      s = sc_idx(j,2);
      idx = (num_transition ...
             + (s-1)*PAR.num_features*PAR.num_plif_nodes ...
             + (f-1)*PAR.num_plif_nodes) ...
            + (1:PAR.num_plif_nodes);
      
      assert(all(score_plifs(j,i).scores==0));
      assert(length(score_plifs(j,i).scores) == PAR.num_plif_nodes);
      res(idx) = score_plifs(j,i).scores'; 
      score_starts(cnt+1) = idx(1);
      cnt = cnt + 1;
    end
  else
    for j=1:size(score_plifs,1), % for all features
      assert(all(score_plifs(j,i).scores==0));
      assert(length(score_plifs(j,i).scores) == PAR.num_plif_nodes);
    end
  end
end
assert(isequal(unique(score_starts), ...
               num_transition+1:PAR.num_plif_nodes:length(res)));
% not a real score_start, but convenient for loops 
score_starts(end+1) = length(res)+1;
num_param = length(res);
num_plif_scores = num_param-num_transition;

%%%   iii) auxiliary variables to implement regularizer
%%%        via constraints (not learning parameters per se)
% auxiliary variables to keep transitions small
aux_starts_small = [];
aux_starts_small(1) = length(res)+1;
res = [res; zeros(num_transition,1)]; 
% auxiliary variables to keep plifs small
for i=1:length(score_starts)-1, 
  aux_starts_small(i+1) = length(res)+1;
  res = [res; zeros(PAR.num_plif_nodes,1)]; 
end
% not a real aux_start, but convenient for loops
aux_starts_small(end+1) = length(res)+1;
num_aux_small = length(res) - num_param;
assert(num_aux_small == aux_starts_small(end)-aux_starts_small(1));
assert(length(aux_starts_small) == length(score_starts)+1);

% auxiliary variables to bound variance of plifs
aux_starts_smooth = [];
for i=1:length(score_starts)-1, 
  aux_starts_smooth(i) = length(res)+1;
  res = [res; zeros(PAR.num_plif_nodes-1,1)]; 
end
% not a real aux_start, but convenient for loops 
aux_starts_smooth(end+1) = length(res)+1;
num_aux_smooth = length(res) - num_param - num_aux_small;
assert(num_aux_smooth == aux_starts_smooth(end)-aux_starts_smooth(1));
assert(length(aux_starts_smooth) == length(score_starts));
num_aux = length(res) - num_param;
assert(num_aux == num_aux_small+num_aux_smooth);

%%%   iv) slack variables
slacks = zeros(PAR.num_exm,1);
res = [res; slacks];

INF = 1e20;

f =  [zeros(num_param,1); ...
      PAR.C_small*ones(num_aux_small,1); ...
      PAR.C_smooth*ones(num_aux_smooth,1); ...
      ones(PAR.num_exm,1)];
lb = [-INF*ones(num_param,1); ...
      zeros(num_aux_small,1); ...
      zeros(num_aux_smooth,1); ...
      zeros(PAR.num_exm,1)];
ub = INF*ones(length(res),1);

A = sparse(zeros(2*num_aux, length(res)));
b = zeros(2*num_aux, 1);

%%% constraints for auxiliary variables
% constraints to keep the problem small
cnt = 1;
aux_idx = aux_starts_small(1):aux_starts_small(2)-1;
assert(length(aux_idx)==num_transition);
for i=1:num_transition,
  % bound the absolute values of transition scores by an auxiliary variable
    %  t_{i} - aux_{i} <= 0
    % -t_{i} - aux_{i} <= 0

    A(cnt, i)   =  1;
    A(cnt, aux_idx(i))  = -1;
    cnt = cnt + 1;

    A(cnt, i)   = -1;
    A(cnt, aux_idx(i))  = -1;
    cnt = cnt + 1;
end
for i=1:length(score_starts)-1,
  sc_idx = score_starts(i):score_starts(i+1)-1;
  aux_idx = aux_starts_small(i+1):aux_starts_small(i+2)-1;
  assert(length(sc_idx) == length(aux_idx));
  for j=1:length(sc_idx),
    % bound the absolute values of scores by an auxiliary variable
    %  scr_{i,j} - aux_{i,j} <= 0
    % -scr_{i,j} - aux_{i,j} <= 0

    A(cnt, sc_idx(j))   =  1;
    A(cnt, aux_idx(j))  = -1;
    cnt = cnt + 1;

    A(cnt, sc_idx(j))   = -1;
    A(cnt, aux_idx(j))  = -1;
    cnt = cnt + 1;
  end 
end

% smoothness constrains
for i=1:length(score_starts)-1,
  sc_idx = score_starts(i):score_starts(i+1)-1;
  aux_idx = aux_starts_smooth(i):aux_starts_smooth(i+1)-1;
  assert(length(sc_idx) == length(aux_idx) + 1);
  for j=1:length(sc_idx)-1,
    % bound the difference between adjacent score values from above and
    % below by an auxiliary variable (which is then regularized):
    %  scr_{i,j} - scr_{i,j+1} - aux_{i,j} <= 0
    % -scr_{i,j} + scr_{i,j+1} - aux_{i,j} <= 0

    A(cnt, sc_idx(j))   =  1;
    A(cnt, sc_idx(j+1)) = -1;
    A(cnt, aux_idx(j))  = -1;
    cnt = cnt + 1;

    A(cnt, sc_idx(j))   = -1;
    A(cnt, sc_idx(j+1)) =  1;
    A(cnt, aux_idx(j))  = -1;
    cnt = cnt + 1;
  end 
end
assert(cnt-1 == length(b));

PAR.num_trans_score = length(transition_scores);
PAR.num_param       = num_param;
PAR.num_aux         = num_aux;
PAR.num_opt_var     = num_param+num_aux+PAR.num_exm;

% eof