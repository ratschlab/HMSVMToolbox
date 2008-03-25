%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% specifies the labelling of tiling array probes according   %%%%%
%%%%% to gene annotation                                         %%%%%
%%%%%                                                            %%%%%
%%%%% written by Georg Zeller, MPI Tuebingen, Germany            %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LABEL = get_label_set()

% LABEL = get_label_set()
% returns a struct with fields specifying probe annotations

LABEL.ambiguous  = -1;

LABEL.intergenic = 0;
LABEL.genic      = 1;
LABEL.intronic   = 2;
LABEL.exonic     = 3;

