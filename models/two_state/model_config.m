function config = model_config()
% config = model_config()

% written by Georg Zeller, MPI Tuebingen, Germany

config.name = 'two_state';
  
config.func_get_state_set = 'get_state_set';
config.func_labels_to_states = 'labels_to_states';
config.func_states_to_labels = 'states_to_labels';
config.func_make_model = 'make_model';
config.func_init_parameters = 'init_parameters';
config.func_init_QP = 'init_QP';
config.func_calc_loss_matrix = 'calc_loss_matrix';

config.func_view_model = 'view_model';
