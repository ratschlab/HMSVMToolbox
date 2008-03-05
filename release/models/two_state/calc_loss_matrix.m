function loss_matrix = calc_loss_matrix(true_state_seq, state_model)
% loss_matrix = calc_loss_matrix(true_state_seq, state_model)
% compute loss matrix |S| x n where S is the set of states 
% and n the length of the true state sequence

% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

FP_loss = 1;
FN_loss = 1;

STATES = get_state_set();

loss = zeros(length(state_model));
loss([STATES.start STATES.negative STATES.stop], STATES.positive) ...
    = FN_loss;
loss(STATES.positive, [STATES.start STATES.negative STATES.stop]) ...
    = FP_loss;

for i=1:length(true_state_seq),
  loss_matrix(:,i) = loss(:,true_state_seq(i));
end
