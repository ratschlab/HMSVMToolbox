function [STATES NUM_LEVELS] = get_state_set()
% [STATES NUM_LEVELS] = get_state_set()
% returns the set of states of the graphical model
%  as well as the number of discrete expression levels
%
% written by Georg Zeller, MPI Tuebingen, Germany

NUM_LEVELS = 10;

STATES = [];

cnt = 1;
STATES.ige         =  cnt; % intergenic
cnt = cnt + 1;
STATES.ige_ss      =  cnt; % splice site state between intergenic probes
cnt = cnt + 1;

for i=1:NUM_LEVELS,
  % exon states
  STATES = setfield(STATES, sprintf('exo_%02i', i), cnt);
  cnt = cnt + 1;

  % splice site states between adjacent probes of
  % the same exon
  STATES = setfield(STATES, sprintf('e_ss_%02i', i), cnt);
  cnt = cnt + 1;

  % splice site state between exo -> ino
  % i.e. donor states (acceptor on (-) strand)
  STATES = setfield(STATES, sprintf('ei_ss_%02i', i), cnt);
  cnt = cnt + 1;

  % splice site state between ino -> exo
  % i.e. acceptor states (donor on (-) strand)
  STATES = setfield(STATES, sprintf('ie_ss_%02i', i), cnt);
  cnt = cnt + 1;

  % intron states
  STATES = setfield(STATES, sprintf('ino_%02i', i), cnt);
  cnt = cnt + 1;

  % splice site states between adjacent probes of
  % the same intron
  STATES = setfield(STATES, sprintf('i_ss_%02i', i), cnt);
  cnt = cnt + 1;
end


