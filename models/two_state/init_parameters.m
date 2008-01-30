function score_plifs = init_parameters(signal, label, STATES, PAR)
% score_plifs = init_parameters(signal, label, STATES, PAR)
% initializes the scoring PLiFs
  
% written by Georg Zeller & Gunnar Raetsch, MPI Tuebingen, Germany

LABELS = get_label_set();

% init a score PLiF for each combination of features and states
num_features = size(signal, 1);
for f=1:num_features,
  s = signal(f,:);
  s = sort(s);

  % determine x values for supporting points of PLiFs
  limits = linspace(1, length(s), PAR.num_plif_nodes+1);
  limits = round((limits(1:end-1)+limits(2:end))/2);
  limits = s(limits);

  for s=1:STATES.num,
    score_plifs(f,s).limits = limits;
    score_plifs(f,s).scores = zeros(size(limits));
    score_plifs(f,s).dim = s;
  end
end

%view_model(STATES, score_plifs);
%keyboard