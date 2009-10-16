function [exm_ids] = reorder_examples(exm_ids, exm_id_intervals, method);

% [exm_ids] = reorder_examples(exm_ids, exm_id_intervals, method);
%
%
%
% written by Georg Zeller, MPI Tuebingen, Germany, 2009

if isequal(method, 'random'),
  perm = randperm(length(exm_ids));
  exm_ids = exm_ids(perm);
elseif isequal(method, 'long_first'),
  idx = find(ismember(exm_id_intervals(:,1),exm_ids));
  len = exm_id_intervals(idx,3)-exm_id_intervals(idx,2)+1;
  [len perm] = sort(len, 1, 'descend');
  exm_ids = exm_ids(perm);
else
  error('unknown reordering strategy %s', method);
end

% eof