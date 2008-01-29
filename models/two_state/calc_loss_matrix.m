function loss_matrix = calc_loss_matrix(true_state_seq, STATES)
% loss_matrix = calc_loss_matrix(true_state_seq, STATES)
% compute loss matrix |S| x n where S is the set of states 
% and n the length of the true state sequence

loss = zeros(STATES.num);
FP_loss = 1;
FN_loss = 1;

loss([STATES.start STATES.negative STATES.stop], STATES.positive) ...
    = FN_loss;
loss(STATES.positive, [STATES.start STATES.negative STATES.stop]) ...
    = FP_loss;

for i=1:length(true_state_seq),
  loss_matrix(:,i) = loss(:,true_state_seq(i));
end
