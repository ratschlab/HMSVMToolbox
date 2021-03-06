function opt_env = opt_license(waitflag, license_no)

% opt_env = opt_license([waitflag], [license_no])
%
% Gets a CPLEX license and returns an environmental pointer to this
% solver instance.
%
% waitflag -- optional parameter (default: 0), if 1, getting a license
%   will be retried every 60 sec at inifinitum or until successful
% license_no -- optional parameter to specify a certain license manager
%   if there are several
% returns an environmental pointer to the CPLEX solver instance.
%
% written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany, 2008

warning off MATLAB:typeaheadBufferOverflow

global opt_env;

if nargin<1, 
  waitflag = 0; 
end
if nargin<2, 
  license_no = -1;
end

%%% Adjust this to your local CPLEX license manager
%%% and comment the error command when done
%error('Please set the paths to the CPLEX license manager in ..../opt_interface/cplex/opt_license.m');

opt_license_path = '/fml/ag-raetsch/share/software/ilog/licenses/';
opt_license_env = {...
    ['ILOG_LICENSE_FILE=' opt_license_path 'access-820980.ilm'], ...
    ['ILOG_LICENSE_FILE=' opt_license_path 'access-703040.ilm'], ...
    ['ILOG_LICENSE_FILE=' opt_license_path 'access-587380.ilm'], ...
                  };


if license_no == -1,
  envstr = getenv('ILOG_LICENSE_FILE');
else
  envstr = opt_license_env{license_no};
end
fprintf('Getting cplex license from %s\n', envstr);
opt_env = cplex_init_quit(0, envstr);
if opt_env==0,
   fprintf('Failed to get cplex license from %s; trying other license managers...\n', envstr);
else
   fprintf('Succeeded to get cplex license from %s\n', envstr);
end

n = 1;
while opt_env==0,
  for n=1:length(opt_license_env),
    envstr = opt_license_env{n};
    fprintf('Trying to get cplex license from %s\n', envstr);
    opt_env = cplex_init_quit(0, envstr);
    if opt_env==0,
      fprintf('Failed to get cplex license from %s\n', envstr);
    else
      fprintf('Succeeded to get cplex license from %s\n', envstr);
      break
    end
  end
  if opt_env==0,
    if ~waitflag,
      break
    else
      disp('waiting for cplex license');
      pause(60);
    end
  end
end
fprintf('\n');
