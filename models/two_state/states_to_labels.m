function label_seq = states_to_labels(state_seq, STATES)
% label_seq = states_to_labels(state_seq, STATES)
% converts a state sequence into label sequence

LABELS = get_label_set();

label_seq = repmat(LABELS.negative, 1, length(state_seq));
label_seq(state_seq==STATES.positive) = LABELS.positive;