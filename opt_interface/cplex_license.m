function lpenv = cplex_license(waitflag, num_cpus)
%  lpenv = cplex_license(waitflag, num_cpus)

warning off MATLAB:typeaheadBufferOverflow

global lpenv;

if nargin<1, 
  waitflag = 0; 
end
if nargin<2, 
  num_cpus = -1;
end

envstr1 = 'ILOG_LICENSE_FILE=/fml/ag-raetsch/share/software/ilog/licenses/access-820980.ilm';
envstr2 = 'ILOG_LICENSE_FILE=/fml/ag-raetsch/share/software/ilog/licenses/access-703040.ilm';
envstr3 = 'ILOG_LICENSE_FILE=/fml/ag-raetsch/share/software/ilog/licenses/access-587380.ilm';

if num_cpus == -1,
  envstr = getenv('ILOG_LICENSE_FILE');
elseif num_cpus == 1,
  envstr = envstr1;
elseif num_cpus == 2,
  envstr = envstr2;
elseif num_cpus > 2,
  envstr = envstr3;
end
fprintf('Getting cplex license from %s\n', envstr);

lpenv = 0;
while (lpenv==0)
  lpenv = cplex_init_quit(0, envstr);
  if lpenv==0,
    fprintf('Failed to get cplex license from %s\n', envstr);
    fprintf('Trying to get cplex license from %s\n', envstr1);
    lpenv = cplex_init_quit(0, envstr1);
  end
  if lpenv==0,
    fprintf('Failed to get cplex license from %s\n', envstr1);
    fprintf('Trying to get cplex license from %s\n', envstr2);
    lpenv = cplex_init_quit(0, envstr2);
  end
  if lpenv==0,
    fprintf('Failed to get cplex license from %s\n', envstr2);
    fprintf('Trying to get cplex license from %s\n', envstr3);
    lpenv = cplex_init_quit(0, envstr3);
  end
  if lpenv==0,
    fprintf('Failed to get cplex license from %s\n', envstr3);
    if ~waitflag,
      break
    else
      disp('waiting for cplex license');
      pause(60);
    end
  end
end

