function check = check_path(path, state_model)

% checks whether the given path can possibly be decoded with the given
% model

% written by Georg Zeller, MPI Tuebingen, Germany, 2008

check = logical(1);
c = state_model(path(1)).is_start == 1;
check = check & c;
c = state_model(path(end)).is_stop == 1;
check = check & c;

if ~check,
  return
end

for i=1:length(path)-1,
  c = any(state_model(path(i)).successors == path(i+1));
  check = check & c;
  if ~check,
    i
    path(i)
    path(i+1)
    state_model(path(i)).successors
    keyboard;
  end
end