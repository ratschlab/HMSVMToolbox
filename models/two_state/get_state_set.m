function STATES = get_state_set(PAR)
% STATES = get_state_set(PAR)
% returns the set of states of the graphical model

% written by Georg Zeller, MPI Tuebingen, Germany

STATES          = [];
STATES.start    = 1;
STATES.stop     = 2;
STATES.negative = 3;
STATES.positive = 4;
