function [state_model, A, a_trans] = make_model(PAR, transition_scores)
% function [state_model, A, a_trans] = make_model(PAR, transition_scores)
% definition of the state-transition model

% written by Georg Zeller, MPI Tuebingen, Germany

state_model = specify_model(PAR);
[state_model, A, a_trans] = complete_model(state_model, PAR, ...
                                           transition_scores);