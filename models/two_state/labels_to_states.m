function state_seq = labels_to_states(label_seq, STATES, signal)
% state_seq = labels_to_states(label_seq, STATES, signal)
% converts a label sequence into a state sequence

% written by Georg Zeller, MPI Tuebingen, Germany

LABELS = get_label_set();

state_seq = repmat(STATES.negative, 1,length(label_seq));
% so far, label_seq and state_seq are identical
state_seq(label_seq==LABELS.positive) = STATES.positive;

