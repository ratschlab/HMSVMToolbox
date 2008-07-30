function loss_matrix = calc_loss_matrix(true_state_seq, state_model, PAR)
% loss_matrix = calc_loss_matrix(true_state_seq, state_model)
% compute loss matrix |S| x n where S is the set of states 
% and n the length of the true state sequence

% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

FP_segment_loss = 1;
FN_segment_loss = 1;
level_loss      = 0.1;

STATES = get_state_set(PAR);

exo_idx = strmatch('exo', fn);
NUM_LEVELS = length(exo_idx);
ino_idx = strmatch('ino', fn);
assert(length(ino_idx) == NUM_LEVELS);

loss = zeros(length(state_model));
% Have a loss only for confused segment states (exon/intron/intergenic)
% and zero-loss for splice site state confusions
loss([STATES.ige ino_idx'], exo_idx') ...
    = FN_segment_loss;
loss(exo_idx', [STATES.ige ino_idx']) ...
    = FP_segment_loss;

% Also penalize if expression levels are confused for exon states
% in a manner increasing with level difference
level_lm = zeros(length(STATES.exon));
for i=1:NUM_LEVELS,
  level_lm = level_lm + diag(repmat(i*level_loss,1,NUM_LEVELS-i), i);
  level_lm = level_lm + diag(repmat(i*level_loss,1,NUM_LEVELS-i), -i);
end
loss(exo_idx, exo_idx) = level_lm;

imagesc(loss);
keyboard

for i=1:length(true_state_seq),
  loss_matrix(:,i) = loss(:,true_state_seq(i));
end
