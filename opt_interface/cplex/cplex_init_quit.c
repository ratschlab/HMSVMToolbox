/* lpex3.c, example of using CPXaddrows to solve a problem */

#include <stdio.h>
#include <stdlib.h>
#include "mex.h"
#include <string.h>

#include "cplex.h"
#define STD_OUT stderr

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]
)
{
  long *p_env;
  double *stat_env;
  CPXENVptr     env = NULL;
  int           status, lpstat, display=1;
  double        objval;
  
  if (nrhs > 3) {
    mexErrMsgTxt("Usage: [lpenv,status] = cplex_init_quit(disp[,envstr[,lpenv]])\n(e.g. ILOG_LICENSE_FILE=/etc/access.ilm)");
    return;
  }
  if ((nlhs < 1) || (nlhs > 2)) {
    mexErrMsgTxt("Usage: [lpenv,status] = cplex_init_quit(disp[,envstr[,lpenv]])\n(e.g. ILOG_LICENSE_FILE=/etc/access.ilm)");
    return;
  }

  if (nrhs>0)
  {
      if (mxGetM(prhs[0]) != 0 || mxGetN(prhs[0]) != 0) 
	  {
		  if (!mxIsNumeric(prhs[0]) || mxIsComplex(prhs[0]) 
			  ||  mxIsSparse(prhs[0])
			  || !(mxGetM(prhs[0])==1 && mxGetN(prhs[0])==1)) 
		  {
			  mexErrMsgTxt("1st argument (display) must be "
						   "an integer scalar.");
			  return;
		  }
		  display = *mxGetPr(prhs[0]);
	  } ;
  } ;
  if (nrhs>1)
  {
      if (mxGetM(prhs[1]) != 0 || mxGetN(prhs[1]) != 0) 
	  {
		  char * envstr ;
		  if (!mxIsChar(prhs[1]) || mxIsComplex(prhs[1]) || mxIsNumeric(prhs[1]) 
			  ||  mxIsSparse(prhs[1])) 
		  {
			  mexErrMsgTxt("1st argument (envstr) must be "
						   "an string.");
			  return;
		  }
		  envstr = mxArrayToString(prhs[1]) ;
		  if (envstr)
			  CPXputenv(strdup(envstr));
	  } ;
  } ;

  if (nrhs>2)
  {
	  if (mxGetM(prhs[2]) != 0 || mxGetN(prhs[2]) != 0) {
		  if (!mxIsNumeric(prhs[2]) || mxIsComplex(prhs[2])
			  ||  mxIsSparse(prhs[2])
			  || !mxIsDouble(prhs[2])
			  ||  mxGetN(prhs[2])!=1 ) {
			  mexErrMsgTxt("3rd argument (lpenv) must be "
						   "a column vector.");
			  return;
		  }
		  if (1 != mxGetM(prhs[2])) {
			  mexErrMsgTxt("Dimension error (arg 3).");
			  return;
		  }
		  long *lpenv;
		  lpenv = (long*) mxGetPr(prhs[2]);
		  env = (CPXENVptr) lpenv[0] ;
		  fprintf(stderr,"env_ptr=%ld\n", env) ;
	  }
  }
  
  plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
  
  if (nlhs == 2)
	  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  
  p_env = (long*)mxGetPr(plhs[0]);
  
  if (nlhs == 2)
	  stat_env = (double*) mxGetPr(plhs[1]);
  
  if (nrhs>2)
  {
	  if ( env != NULL ) {
		  if (display>0)
			  fprintf(STD_OUT, "calling CPXcloseCPLEX\n") ;
		  status = CPXcloseCPLEX (&env);
		  
		  /* Note that CPXcloseCPLEX produces no output,
			 so the only way to see the cause of the error is to use
			 CPXgeterrorstring.  For other CPLEX routines, the errors will
			 be seen if the CPX_PARAM_SCRIND indicator is set to CPX_ON. */
		  
		  if ( status ) {
			  char  errmsg[1024];
			  fprintf(STD_OUT, "Could not close CPLEX environment.\n");
			  CPXgeterrorstring(env, status, errmsg);
			  fprintf (STD_OUT, "%s", errmsg);
		  }
	  }
  }
  else
  {
	  /* Initialize the CPLEX environment */
	  
	  if (display>0)
		  fprintf(stderr, "calling CPXopenCPLEX \n") ;
	  env = CPXopenCPLEX (&status);
	  fprintf(stderr, "STATUS %i\n", status);
	  fprintf(stderr,"env_ptr=%ld\n", env) ;
	  /* If an error occurs, the status value indicates the reason for
		 failure.  A call to CPXgeterrorstring will produce the text of
		 the error message.  Note that CPXopenCPLEXdevelop produces no output,
		 so the only way to see the cause of the error is to use
		 CPXgeterrorstring.  For other CPLEX routines, the errors will
		 be seen if the CPX_PARAM_SCRIND indicator is set to CPX_ON.  */
	  
	  if ( env == NULL ) {
		  char  errmsg[1024];
		  fprintf (stderr, "Could not open CPLEX environment.\n");
		  CPXgeterrorstring (env, status, errmsg);
		  fprintf (stderr, "%s", errmsg);
		  
		  if (nlhs == 2)
			  *stat_env = (double) status;
		  
		  goto TERMINATE;
	  }
	  
	  /* Turn on output to the screen */
	  
	  status = CPXsetintparam (env, CPX_PARAM_SCRIND, CPX_ON);
	  if ( status ) {
		  fprintf (stderr, 
				   "Failure to turn on screen indicator, error %d.\n", status);
		  goto TERMINATE;
	  }
	  
	  status = CPXsetintparam (env, CPX_PARAM_SIMDISPLAY, 1);
	  if ( status ) {
		  fprintf (stderr,"Failed to turn up simplex display level.\n");
		  goto TERMINATE;
	  }
  }
  
  *p_env=(long) env ;
  
  return ;
  
TERMINATE:

  
  /* Free up the CPLEX environment, if necessary */
  
  if ( env != NULL ) {
    fprintf(stderr, "calling CPXcloseCPLEX\n") ;
    status = CPXcloseCPLEX (&env);
    
    /* Note that CPXcloseCPLEX produces no output,
       so the only way to see the cause of the error is to use
       CPXgeterrorstring.  For other CPLEX routines, the errors will
       be seen if the CPX_PARAM_SCRIND indicator is set to CPX_ON. */
    
    if ( status ) {
      char  errmsg[1024];
      fprintf (stderr, "Could not close CPLEX environment.\n");
      CPXgeterrorstring (env, status, errmsg);
      fprintf (stderr, "%s", errmsg);
    }
  }
  
} 




