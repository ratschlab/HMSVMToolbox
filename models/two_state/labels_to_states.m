function state_seq = labels_to_states(label_seq, state_model, signal)
% state_seq = labels_to_states(label_seq, state_model, signal)
% converts a label sequence into a state sequence

% written by Georg Zeller, MPI Tuebingen, Germany

LABELS = get_label_set();
STATES = get_state_set();

state_seq = repmat(STATES.negative, 1, length(label_seq));
% so far, label_seq and state_seq are identical
state_seq(label_seq==LABELS.positive) = STATES.positive;
state_seq(1) = STATES.start;
state_seq(end) = STATES.stop;