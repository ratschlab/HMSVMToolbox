function check = check_path(state_seq, state_model)

% check = check_path(state_seq, state_model)
%
% Checks whether the given state_seq can possibly be decoded given the
% allowed transitions in the state model.
%
% state_seq -- a sequence of states
% state_model -- a graphical model which also specifies allowed
%   transitions
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2008

check = logical(1);
c = state_model(state_seq(1)).is_start == 1;
check = check & c;
c = state_model(state_seq(end)).is_stop == 1;
check = check & c;

if ~check,
  return
end

for i=1:length(state_seq)-1,
  c = any(state_model(state_seq(i)).successors == state_seq(i+1));
  check = check & c;
  if ~check,
    i
    state_seq(i)
    state_seq(i+1)
    state_model(state_seq(i)).successors
    keyboard
  end
end