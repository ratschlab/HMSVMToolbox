/* lpex3.c, example of using CPXaddrows to solve a problem */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
/*#include "mcc.h"*/

#include "cplex.h"

const int COPY_DATA=1 ;
const int COPY_SAFE=0 ;
#define myMalloc CPXmalloc 
#define myFree CPXfree
#define STD_OUT stderr

static char *err_str[] = {
  "OK",
  "CPX_STAT_OPTIMAL",
  "CPX_STAT_UNBOUNDED",
  "CPX_STAT_INFEASIBLE",
  "CPX_STAT_INForUNBD",
  "CPX_STAT_OPTIMAL_INFEAS",
  "CPX_STAT_NUM_BEST",
  "CPX_STAT_FEASIBLE_RELAXED",
  "CPX_STAT_OPTIMAL_RELAXED",
  "?",
  "CPX_STAT_ABORT_IT_LIM",
  "CPX_STAT_ABORT_TIME_LIM",
  "CPX_STAT_ABORT_OBJ_LIM",
  "CPX_STAT_ABORT_USER",
  "Aborted in barrier, dual infeasible ",
  "Aborted in barrier, primal infeasible",
  "Aborted in barrier, primal and dual infeasible",
  "Aborted in barrier, primal and dual feasible",
  "Aborted in crossover",
  "Infeasible or unbounded",
  "","","","","","","","","","","","",
  "Converged, dual feasible, primal infeasible", /* 32 */
  "Converged, primal feasible, dual infeasible",
  "Converged, primal and dual infeasible",
  "Primal objective limit reached",
  "Dual objective limit reached",
  "Primal has unbounded optimal face",
  "Non-optimal solution found, primal-dual feasible",
  "Non-optimal solution found, primal infeasible",
  "Non-optimal solution found, dual infeasible",
  "Non-optimal solution found, primal-dual infeasible",
  "Non-optimal solution found, numerical difficulties",
  "Barrier found inconsistent constraints",
  "",
};

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]
)
{
  int i, j;
  double *c=NULL, *b=NULL, *A=NULL, 
    *l=NULL, *u=NULL, *x=NULL, *lambda=NULL ;
  int *iA=NULL, *kA=NULL ;
#ifndef MX_COMPAT_32
  long *iA_=NULL, *kA_=NULL ;
#endif
  int *nzA=NULL, neq=0, m=0, n=0, display=0;
  long *lpenv=NULL, *p_lp=NULL;
  char *Sense=NULL ;
  CPXENVptr     env = NULL;
  CPXLPptr      lp = NULL;
  int           status, lpstat;
  double        objval;
  char          opt_method[128]="auto" ;
  
  if (nrhs > 9 || nrhs < 1) {
    mexErrMsgTxt("Usage: [x,lambda,how,p_lp] "
		 "= lp_solve(lpenv,c,A,b,l,u,neq,disp,method)");
    return;
  }
  switch (nrhs) {
  case 9:
    if (mxGetM(prhs[8]) != 0 || mxGetN(prhs[8]) != 0) {
      if (mxIsNumeric(prhs[8]) || mxIsComplex(prhs[8]) || !mxIsChar(prhs[8]) 
	  ||  mxIsSparse(prhs[8])
	  || !(mxGetM(prhs[8])==1 && mxGetN(prhs[8])>=1)) {
	mexErrMsgTxt("9th argument (method) must be "
		     "a string.");
	return;
      }
      mxGetString(prhs[8], opt_method, 128) ;
    }
  case 8:
    if (mxGetM(prhs[7]) != 0 || mxGetN(prhs[7]) != 0) {
      if (!mxIsNumeric(prhs[7]) || mxIsComplex(prhs[7]) 
	  ||  mxIsSparse(prhs[7])
	  || !(mxGetM(prhs[7])==1 && mxGetN(prhs[7])==1)) {
	mexErrMsgTxt("8th argument (display) must be "
		     "an integer scalar.");
	return;
      }
      display = *mxGetPr(prhs[7]);
    }
  case 7:
    if (mxGetM(prhs[6]) != 0 || mxGetN(prhs[6]) != 0) {
      if (!mxIsNumeric(prhs[6]) || mxIsComplex(prhs[6]) 
	  ||  mxIsSparse(prhs[6])
	  || !(mxGetM(prhs[6])==1 && mxGetN(prhs[6])==1)) {
	mexErrMsgTxt("7th argument (neqcstr) must be "
		     "an integer scalar.");
	return;
      }
      neq = *mxGetPr(prhs[6]);
    }
  case 6:
    if (mxGetM(prhs[4]) != 0 || mxGetN(prhs[4]) != 0) {
      if (!mxIsNumeric(prhs[4]) || mxIsComplex(prhs[4]) 
	  ||  mxIsSparse(prhs[4])
	  || !mxIsDouble(prhs[4]) 
	  ||  mxGetN(prhs[4])!=1 ) {
	mexErrMsgTxt("6th argument (u) must be "
		     "a column vector.");
	return;
      }
      u = mxGetPr(prhs[5]);
      n = mxGetM(prhs[5]);
    }
  case 5:
    if (mxGetM(prhs[4]) != 0 || mxGetN(prhs[4]) != 0) {
      if (!mxIsNumeric(prhs[4]) || mxIsComplex(prhs[4]) 
	  ||  mxIsSparse(prhs[4])
	  || !mxIsDouble(prhs[4]) 
	  ||  mxGetN(prhs[4])!=1 ) {
	mexErrMsgTxt("5th argument (l) must be "
		     "a column vector.");
	return;
      }
      if (n != 0 && n != mxGetM(prhs[4])) {
	mexErrMsgTxt("Dimension error (arg 5 and later).");
	return;
      }
      l = mxGetPr(prhs[4]);
      n = mxGetM(prhs[4]);
    }
  case 4:
    if (mxGetM(prhs[3]) != 0 || mxGetN(prhs[3]) != 0) {
      if (!mxIsNumeric(prhs[3]) || mxIsComplex(prhs[3]) 
	  ||  mxIsSparse(prhs[3])
	  || !mxIsDouble(prhs[3]) 
	  ||  mxGetN(prhs[3])!=1 ) {
	mexErrMsgTxt("4rd argument (b) must be "
		     "a column vector.");
	return;
      }
      if (m != 0 && m != mxGetM(prhs[3])) {
	mexErrMsgTxt("Dimension error (arg 4 and later).");
	return;
      }
      b = mxGetPr(prhs[3]);
      m = mxGetM(prhs[3]);
    }
  case 3:
    if (mxGetM(prhs[2]) != 0 || mxGetN(prhs[2]) != 0) {
      if (!mxIsNumeric(prhs[2]) || mxIsComplex(prhs[2]) 
	  || !mxIsSparse(prhs[2]) ) {
	mexErrMsgTxt("3n argument (A) must be "
		     "a sparse matrix.");
	return;
      }
      if (m != 0 && m != mxGetM(prhs[2])) {
	mexErrMsgTxt("Dimension error (arg 3 and later).");
	return;
      }
      if (n != 0 && n != mxGetN(prhs[2])) {
	mexErrMsgTxt("Dimension error (arg 3 and later).");
	return;
      }
      m = mxGetM(prhs[2]);
      n = mxGetN(prhs[2]);
      
      A = mxGetPr(prhs[2]);
#ifdef MX_COMPAT_32
      iA = mxGetIr(prhs[2]);
      kA = mxGetJc(prhs[2]);
#else
      iA_ = mxGetIr(prhs[2]);
      kA_ = mxGetJc(prhs[2]);

	  iA = myMalloc(mxGetNzmax(prhs[2])*sizeof(int)) ;
	  for (i=0; i<mxGetNzmax(prhs[2]); i++)
		  iA[i]=iA_[i] ;
	  
	  kA = myMalloc((n+1)*sizeof(int)) ;
	  for (i=0; i<n+1; i++)
		  kA[i]=kA_[i] ;
#endif
      nzA=myMalloc(n*sizeof(int)) ;
      for (i=0; i<n; i++)
		  nzA[i]=kA[i+1]-kA[i] ;
      
      Sense=myMalloc((m+1)*sizeof(char)) ;
      for (i=0; i<m; i++)
		  if (i<neq) Sense[i]='E' ;
		  else Sense[i]='L' ;
      Sense[m]=0 ;
    }
  case 2:
	  if (mxGetM(prhs[1]) != 0 || mxGetN(prhs[1]) != 0) {
      if (!mxIsNumeric(prhs[1]) || mxIsComplex(prhs[1]) 
		  ||  mxIsSparse(prhs[1])
		  || !mxIsDouble(prhs[1]) 
		  ||  mxGetN(prhs[1])!=1 ) {
		  mexErrMsgTxt("2st argument (c) must be "
					   "a column vector.");
		  return;
      }
      if (n != 0 && n != mxGetM(prhs[1])) {
		  mexErrMsgTxt("Dimension error (arg 2 and later).");
		  return;
      }
      c = mxGetPr(prhs[1]);
      n = mxGetM(prhs[1]);
	  }
  case 1:
	  if (mxGetM(prhs[0]) != 0 || mxGetN(prhs[0]) != 0) {
		  if (!mxIsNumeric(prhs[0]) || mxIsComplex(prhs[0]) 
			  ||  mxIsSparse(prhs[0])
			  || !mxIsDouble(prhs[0]) 
			  ||  mxGetN(prhs[0])!=1 ) {
			  mexErrMsgTxt("1st argument (lpenv) must be "
						   "a column vector.");
			  return;
		  }
		  if (1 != mxGetM(prhs[0])) {
			  mexErrMsgTxt("Dimension error (arg 1).");
			  return;
		  }
		  lpenv = (long*) mxGetPr(prhs[0]);
	  }
  }
  
  /* Initialize the CPLEX environment */
  env = (CPXENVptr) lpenv[0] ;
  
  /* Turn on output to the screen */
  if (display>0)
	  status = CPXsetintparam (env, CPX_PARAM_SCRIND, CPX_ON);
  else
	  status = CPXsetintparam (env, CPX_PARAM_SCRIND, CPX_OFF);
  if ( status ) {
	  fprintf (STD_OUT, 
			   "Failure to turn on screen indicator, error %d.\n", status);
	  goto TERMINATE;
  }
  
  status = CPXsetintparam (env, CPX_PARAM_SIMDISPLAY, display);
  if ( status ) {
	  fprintf (STD_OUT,"Failed to turn up simplex display level.\n");
	  goto TERMINATE;
  }
  
  status= CPXsetstrparam  (env, CPX_PARAM_WORKDIR, "/tmp/") ;
  if ( status ) {
	  fprintf (STD_OUT,"Failed to set OOC work directory.\n");
	  goto TERMINATE;
  }
  
  if (strcmp(opt_method, "primal") &&  
	  strcmp(opt_method, "dual") &&
      strcmp(opt_method, "bar") && 
	  strcmp(opt_method, "hybbar") &&
	  strcmp(opt_method, "hybbar-d") &&
	  strcmp(opt_method, "hybbar-p") &&
      strcmp(opt_method, "hybnet") && 
      strcmp(opt_method, "hybnet-d") && 
      strcmp(opt_method, "hybnet-p") && 
      strcmp(opt_method, "sift") && 
      strcmp(opt_method, "lp") && 
	  strcmp(opt_method, "auto"))
    mxErrMsgTxt("method \\in " 
		"{'lp','primal','dual','bar','hybbar','hybnet','hybnet-p','hybnet-d','hybbar-p',hybbar-d','sift','auto'}\n") ;
  
  if (nlhs > 4 || nlhs < 1) {
    mexErrMsgTxt("Usage: [x,lambda,how,p_lp] "
		 "= lp_solve(lpenv,c,A,b,l,u,neq,disp,method)");
    return;
  }
  if (display>3) fprintf(STD_OUT, "(m=%i, n=%i, neq=%i) \n", m, n, neq) ;

  switch (nlhs) {
  case 4:
    plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
    p_lp = (long*) mxGetPr(plhs[3]);
  case 3:
  case 2:
    plhs[1] = mxCreateDoubleMatrix(m, 1, mxREAL);
    lambda = mxGetPr(plhs[1]);
  case 1:
    plhs[0] = mxCreateDoubleMatrix(n, 1, mxREAL);
    x = mxGetPr(plhs[0]);
    break;
  }
  if (display>2) fprintf(STD_OUT, "argument processing finished\n") ;
    
  /* Create the problem */    
  if (display>2) fprintf(STD_OUT, "calling CPXcreateprob \n") ;
  lp = CPXcreateprob (env, &status, "xxx");
  if ( lp == NULL ) {
	  fprintf (STD_OUT,"Failed to create subproblem\n");
	  status = 1;
	  goto TERMINATE;
  } 
  if (p_lp) *p_lp=(long) lp ;
  
  if (display>2) 
	  fprintf(STD_OUT, "calling CPXcopylp (m=%i, n=%i) \n", m, n) ;
	  status = CPXcopylp(env, lp, n, m, CPX_MIN, c, b, 
						 Sense, kA, nzA, iA, A, 
						 l, u, NULL);
  if ( status ) {
	  fprintf (STD_OUT, "CPXcopylp failed.\n");
	  goto TERMINATE;
  }
  
  if (display>2) 
    fprintf(STD_OUT, "calling optimizer '%s'\n", opt_method) ;

  if (!strcmp(opt_method, "primal"))
    status = CPXprimopt (env, lp);
  else if (!strcmp(opt_method, "dual"))
    status = CPXdualopt (env, lp);
  else if (!strcmp(opt_method, "bar"))
    status = CPXbaropt (env, lp);
  else if (!strcmp(opt_method, "lp"))
    status = CPXbaropt (env, lp);
  else if (!strcmp(opt_method, "hybbar"))
    status = CPXhybbaropt (env, lp, CPX_ALG_NONE);
  else if (!strcmp(opt_method, "hybnet"))
    status = CPXhybnetopt (env, lp, CPX_ALG_NONE);
  else if (!strcmp(opt_method, "hybbar-p"))
    status = CPXhybbaropt (env, lp, CPX_ALG_PRIMAL);
  else if (!strcmp(opt_method, "hybnet-p"))
    status = CPXhybnetopt (env, lp, CPX_ALG_PRIMAL);
  else if (!strcmp(opt_method, "hybbar-d"))
    status = CPXhybbaropt (env, lp, CPX_ALG_DUAL);
  else if (!strcmp(opt_method, "hybnet-d"))
    status = CPXhybnetopt (env, lp, CPX_ALG_DUAL);
  else if (!strcmp(opt_method, "sift"))
    status = CPXsiftopt (env, lp);
  else if (!strcmp(opt_method, "auto")) {
	  status = CPXdualopt (env, lp);
	  if ( !status ) 
		  status = CPXsolution (env, lp, &lpstat, &objval, x, lambda, NULL, NULL);
	  if (status || (lpstat!=1)) {
		  if (display>1) 
			  fprintf (STD_OUT,"CPXdualopt failed (%i:%i).\n", status, lpstat);
		  status = CPXprimopt (env, lp);
		  if ( !status ) 
			  status=CPXsolution (env, lp, &lpstat, &objval, x, lambda, NULL, NULL);
		  if (status || (lpstat!=1)) {
			  if (display>1) 
				  fprintf (STD_OUT,"CPXprimopt failed (%i:%i).\n", status, lpstat);
			  status = CPXbaropt (env, lp);
			  strcpy(opt_method, "bar") ;
		  } ;
	  } ;
  }
  else 
    fprintf(STD_OUT, "bad method\n") ;
  
  /*if (display>3)*/
    fprintf(STD_OUT, "CPX%sopt=%i\n", opt_method, status) ;
  if ( status ) {
    fprintf (STD_OUT,"CPX%sopt failed (%i).\n", opt_method, status);
    goto TERMINATE;
  }
  
  if (display>2)
    fprintf(STD_OUT, "calling CPXsolution\n") ;
  status = CPXsolution (env, lp, &lpstat, &objval, x, lambda, NULL, NULL);
  if ( status ) {
    fprintf (STD_OUT,"CPXsolution failed.\n");
    goto TERMINATE;
  }
  
  if (display>1)
    fprintf (STD_OUT, "Solution status: %s\n", err_str[lpstat]);
  if (display>2)
    fprintf (STD_OUT, "Objective value %g\n", objval);
  
  if (nlhs >= 3) 
    if (lpstat==1)
      plhs[2] = mxCreateString(err_str[0]) ;
    else
      plhs[2] = mxCreateString(err_str[lpstat]) ;

 TERMINATE:
  if (status) {
    char  errmsg[1024];
    CPXgeterrorstring (env, status, errmsg);
    fprintf (STD_OUT, "%s", errmsg);
    if (nlhs >= 3) 
      plhs[2] = mxCreateString(errmsg) ;
  } ;

  if (nzA) myFree(nzA) ;

#ifndef MX_COMPAT_32
  if (iA) myFree(iA) ;
  if (kA) myFree(kA) ;
#endif

  /*if (Sense) myFree(Sense) ;*/
  if (!p_lp)
    {
      if ( lp != NULL ) {
	if (display>2)
	  fprintf(STD_OUT, "calling CPXfreeprob\n") ;
	status = CPXfreeprob (env, &lp);
	if ( status ) {
	  fprintf (STD_OUT, "CPXfreeprob failed, error code %d.\n", status);
	}
      }
    }
  return ;
}     
