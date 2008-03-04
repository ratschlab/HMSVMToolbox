function [A b Q f lb ub slacks res res_map PAR] = init_QP(transition_scores, score_plifs, state_model, PAR)
% [A b Q f lb ub slacks res res_map PAR] = init_QP(transition_scores, score_plifs, state_model, PAR)
% initialize QP

% written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany

% optimization paramaters: 
%   i) transition scores
res = transition_scores;
num_transition = length(res);

next_score_start = length(res)+1;
% mapping (features, states) -> position in res vector
res_map = zeros(PAR.num_features, length(state_model));
% coupling ((feature; state); (feature; state))
coupling_idx = zeros(4,0);
cnt = 1;
for i=1:length(state_model), % for all states
  idx = find(state_model(i).learn_scores);
  for j=1:length(idx),
    row_idx = state_model(i).feature_scores(j,1);
    col_idx = state_model(i).feature_scores(j,2);
    if res_map(row_idx, col_idx) == 0,
      res_map(row_idx, col_idx) = next_score_start;
      score_starts(cnt) = next_score_start;
      next_score_start = next_score_start + PAR.num_plif_nodes;
      cnt = cnt + 1;
    end
    if i~=col_idx || idx(j)~=row_idx, 
      res_map(idx(j), i) = res_map(row_idx, col_idx);
    end
    if state_model(i).score_coupling(j,1) ~= 0,
      assert(state_model(i).score_coupling(j,2) ~= 0);
      coupling_idx = [coupling_idx, [idx(j); ...
                          i; ...
                          state_model(i).score_coupling(j,1); ...
                          state_model(i).score_coupling(j,2)]];
    end
  end
end
% not a real score_start, but convenient for loops 
score_starts(end+1) = next_score_start;

%   ii) y-values of PLiF supporting points (feature scoring functions)
for t=1:PAR.num_features, % for all features
  for s=1:length(state_model), % for all states
    assert(length(score_plifs(t,s).scores) == PAR.num_plif_nodes);
    if res_map(t,s) == 0,
      assert(all(score_plifs(t,s).scores==0));
    else
      res(res_map(t,s):res_map(t,s)+PAR.num_plif_nodes-1) ...
          = score_plifs(t,s).scores'; 
    end
  end
end
num_param = length(res);
assert(length(res) == score_starts(end) - 1);
num_plif_scores = num_param - num_transition;

%   iii) auxiliary variables to implement smoothness regularizer
%        via constraints (not learning parameters per se)
for i=1:length(score_starts)-1, 
  aux_starts_smooth(i) = length(res)+1;
  res = [res; zeros(PAR.num_plif_nodes-1,1)]; 
end
% not a real aux_start, but convenient for loops 
aux_starts_smooth(end+1) = length(res)+1;
assert(length(aux_starts_smooth) == length(score_starts));
num_aux_smooth = length(res) - num_param;

% auxiliary variables to couple plifs across states
aux_starts_coupling = [];
for i=1:size(coupling_idx,2),
  aux_starts_coupling(i) = length(res)+1;
  res = [res; zeros(PAR.num_plif_nodes,1)]; 
end
% not a real aux_start, but convenient for loops
aux_starts_coupling(end+1) = length(res)+1;
num_aux_coupling = length(res) - num_param - num_aux_smooth;
num_aux = length(res) - num_param;
assert(size(coupling_idx,2)*PAR.num_plif_nodes == num_aux_coupling);
assert(num_aux == num_aux_smooth+num_aux_coupling);

%   iv) slack variables
slacks = zeros(PAR.num_exm,1);
res = [res; slacks];
 
% quadratic regularizer to keep PLiF values small
Q = sparse(zeros(length(res)));
Q(1:num_param,1:num_param) = PAR.C_small*eye(num_param);
% quadratic regularizer to keep PLiFs smooth
Q(num_param+1:num_param+num_aux_smooth,num_param+1:num_param+num_aux_smooth) ...
    = PAR.C_smooth*eye(num_aux_smooth);
% quadratic regularizer to couple PLiFs
Q(num_param+num_aux_smooth+1:num_param+num_aux, ...
  num_param+num_aux_smooth+1:num_param+num_aux) ...
    = PAR.C_coupling*eye(num_aux_coupling);

INF = 1e20;

f = [zeros(num_param+num_aux,1); ones(PAR.num_exm,1)];
lb = [-INF*ones(num_param,1); zeros(num_aux+PAR.num_exm,1)];
ub = INF*ones(length(res),1);

A = sparse(zeros(2*num_aux, length(res)));
b = zeros(2*num_aux, 1);

% smoothness constraints
cnt = 1;
for i=1:length(score_starts)-1,
  sc_idx = score_starts(i):score_starts(i+1)-1;
  aux_idx = aux_starts_smooth(i):aux_starts_smooth(i+1)-1;
  for j=1:length(sc_idx)-1,
    % bound the difference between adjacent score values from above and
    % below by an auxiliary variable (which is then regularized quadratically):
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

% constraints for score coupling
for i=1:size(coupling_idx,2),
  sc_idx_1 = res_map(coupling_idx(1,i), coupling_idx(2,i));
  sc_idx_1 = sc_idx_1:sc_idx_1+PAR.num_plif_nodes-1;
  sc_idx_2 = res_map(coupling_idx(3,i), coupling_idx(4,i));
  sc_idx_2 = sc_idx_2:sc_idx_2+PAR.num_plif_nodes-1;
  aux_idx = aux_starts_coupling(i):aux_starts_coupling(i+1)-1;
  assert(length(sc_idx_1) == length(sc_idx_2));
  assert(length(sc_idx) == length(aux_idx));
  for j=1:length(aux_idx),
    % bound the difference between corresponding score value pairs from
    % above and  below by an auxiliary variable (which is then regularized):
    %  scr_{i1,j} - scr_{i2,j} - aux_{i,j} <= 0
    % -scr_{i1,j} + scr_{i2,j} - aux_{i,j} <= 0
    
    A(cnt, sc_idx_1(j)) =  1;
    A(cnt, sc_idx_2(j)) = -1;
    A(cnt, aux_idx(j))  = -1;
    cnt = cnt + 1;

    A(cnt, sc_idx_1(j)) = -1;
    A(cnt, sc_idx_2(j)) =  1;
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