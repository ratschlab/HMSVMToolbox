/* lpex3.c, example of using CPXaddrows to solve a problem */

#include <stdio.h>
#include <stdlib.h>
#include "mex.h"

#include "cplex.h"

#define myMalloc CPXmalloc 
#define myFree CPXfree 
#define STD_OUT stderr

static char *err_str[] = {
  "OK",
  "Optimal solution found", /* 1 */
  "Problem infeasible",
  "Problem unbounded",
  "Model is proved either infeasible of unbounded",
  "Optimal solution is available, but with infeasibilities after unscaling",
  "Solution is available, but not proved optimal (numerical difficulties)",
  "Time limit exceeded in Phase II",
  "Time limit exceeded in Phase I",
  "Problem non-optimal, singularities in Phase II",
  "Problem non-optimal, singularities in Phase I",
  "Optimal solution found, unscaled infeasibilities",
  "Aborted in Phase II",
  "Aborted in Phase I",
  "Aborted in barrier, dual infeasible ",
  "Aborted in barrier, primal infeasible",
  "Aborted in barrier, primal and dual infeasible",
  "Aborted in barrier, primal and dual feasible",
  "Aborted in crossover  ",
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
  double *c=NULL, *b=NULL, *A=NULL, *H=NULL,
    *l=NULL, *u=NULL, *x=NULL, *lambda=NULL ;
  int *nzA=NULL, *nzH=NULL ;
  int *iA=NULL, *kA=NULL ;
  int *iH=NULL, *kH=NULL ;
#ifndef MX_COMPAT_32
  long *iA_=NULL, *kA_=NULL ;
  long *iH_=NULL, *kH_=NULL ;
#endif 
  int neq=0, m=0, n=0, display=0;
  long *cpenv=NULL, *p_qp=NULL;
  char *Sense=NULL ;
  CPXENVptr     env = NULL;
  CPXLPptr      qp = NULL;
  int           status, qpstat;
  double        objval;
  double * p_qpstat ;
  char          opt_method[128]="auto" ;
  
  if (nrhs > 10 || nrhs < 1) {
    mexErrMsgTxt("Usage: [x,lambda,how,p_qp] "
		 "= qp_solve(cpenv,Q,c,A,b,l,u,neq,disp,method)");
    return;
  }
  switch (nrhs) {
  case 10:
	  if (mxGetM(prhs[9]) != 0 || mxGetN(prhs[9]) != 0) {
		  if (mxIsNumeric(prhs[9]) || mxIsComplex(prhs[9]) || !mxIsChar(prhs[9]) 
			  ||  mxIsSparse(prhs[9])
			  || !(mxGetM(prhs[9])==1 && mxGetN(prhs[9])>=1)) {
			  mexErrMsgTxt("10th argument (method) must be "
						   "a string.");
			  return;
		  }
		  mxGetString(prhs[9], opt_method, 128) ;
	  }
  case 9:
    if (mxGetM(prhs[8]) != 0 || mxGetN(prhs[8]) != 0) {
      if (!mxIsNumeric(prhs[8]) || mxIsComplex(prhs[8]) 
	  ||  mxIsSparse(prhs[8])
	  || !(mxGetM(prhs[8])==1 && mxGetN(prhs[8])==1)) {
	mexErrMsgTxt("9th argument (display) must be "
		     "an integer scalar.");
	return;
      }
      display = *mxGetPr(prhs[8]);
    }
  case 8:
    if (mxGetM(prhs[7]) != 0 || mxGetN(prhs[7]) != 0) {
      if (!mxIsNumeric(prhs[7]) || mxIsComplex(prhs[7]) 
	  ||  mxIsSparse(prhs[7])
	  || !(mxGetM(prhs[7])==1 && mxGetN(prhs[7])==1)) {
	mexErrMsgTxt("8th argument (neqcstr) must be "
		     "an integer scalar.");
	return;
      }
      neq = *mxGetPr(prhs[7]);
    }
  case 7:
    if (mxGetM(prhs[6]) != 0 || mxGetN(prhs[6]) != 0) {
      if (!mxIsNumeric(prhs[6]) || mxIsComplex(prhs[6]) 
	  ||  mxIsSparse(prhs[6])
	  || !mxIsDouble(prhs[6]) 
	  ||  mxGetN(prhs[6])!=1 ) {
	mexErrMsgTxt("7th argument (u) must be "
		     "a column vector.");
	return;
      }
      u = mxGetPr(prhs[6]);
      n = mxGetM(prhs[6]);
    }
  case 6:
    if (mxGetM(prhs[5]) != 0 || mxGetN(prhs[5]) != 0) {
      if (!mxIsNumeric(prhs[5]) || mxIsComplex(prhs[5]) 
	  ||  mxIsSparse(prhs[5])
	  || !mxIsDouble(prhs[5]) 
	  ||  mxGetN(prhs[5])!=1 ) {
	mexErrMsgTxt("6th argument (l) must be "
		     "a column vector.");
	return;
      }
      if (n != 0 && n != mxGetM(prhs[5])) {
	mexErrMsgTxt("Dimension error (arg 6 and later).");
	return;
      }
      l = mxGetPr(prhs[5]);
      n = mxGetM(prhs[5]);
    }
  case 5:
    if (mxGetM(prhs[4]) != 0 || mxGetN(prhs[4]) != 0) {
      if (!mxIsNumeric(prhs[4]) || mxIsComplex(prhs[4]) 
	  ||  mxIsSparse(prhs[4])
	  || !mxIsDouble(prhs[4]) 
	  ||  mxGetN(prhs[4])!=1 ) {
	mexErrMsgTxt("5th argument (b) must be "
		     "a column vector.");
	return;
      }
      if (m != 0 && m != mxGetM(prhs[4])) {
	mexErrMsgTxt("Dimension error (arg 5 and later).");
	return;
      }
      b = mxGetPr(prhs[4]);
      m = mxGetM(prhs[4]);
    }
  case 4:
    if (mxGetM(prhs[3]) != 0 || mxGetN(prhs[3]) != 0) {
      if (!mxIsNumeric(prhs[3]) || mxIsComplex(prhs[3]) 
	  || !mxIsSparse(prhs[3]) ) {
	mexErrMsgTxt("4th argument (A) must be "
		     "a sparse matrix.");
	return;
      }
      if (m != 0 && m != mxGetM(prhs[3])) {
	mexErrMsgTxt("Dimension error (arg 4 and later).");
	return;
      }
      if (n != 0 && n != mxGetN(prhs[3])) {
	mexErrMsgTxt("Dimension error (arg 4 and later).");
	return;
      }
      m = mxGetM(prhs[3]);
      n = mxGetN(prhs[3]);
      
      A = mxGetPr(prhs[3]);
#ifdef MX_COMPAT_32
      iA = mxGetIr(prhs[3]);
      kA = mxGetJc(prhs[3]);
#else
      iA_ = mxGetIr(prhs[3]);
      kA_ = mxGetJc(prhs[3]);

	  iA = (int*)malloc(mxGetNzmax(prhs[3])*sizeof(int)) ;
	  for (i=0; i<mxGetNzmax(prhs[3]); i++)
		  iA[i]=iA_[i] ;

	  kA = (int*)malloc((n+1)*sizeof(int)) ;
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
  case 3:
    if (mxGetM(prhs[2]) != 0 || mxGetN(prhs[2]) != 0) {
      if (!mxIsNumeric(prhs[2]) || mxIsComplex(prhs[2]) 
	  ||  mxIsSparse(prhs[2])
	  || !mxIsDouble(prhs[2]) 
	  ||  mxGetN(prhs[2])!=1 ) {
	mexErrMsgTxt("3rd argument (c) must be "
		     "a column vector.");
	return;
      }
      if (n != 0 && n != mxGetM(prhs[2])) {
	mexErrMsgTxt("Dimension error (arg 3 and later).");
	return;
      }
      c = mxGetPr(prhs[2]);
      n = mxGetM(prhs[2]);
    }
  case 2:
    if (mxGetM(prhs[1]) != 0 || mxGetN(prhs[1]) != 0) {
      if (!mxIsNumeric(prhs[1]) || mxIsComplex(prhs[1]) 
	  || !mxIsSparse(prhs[1]) ) {
	mexErrMsgTxt("2nd argument (H) must be "
		     "a sparse matrix.");
	return;
      }
      if (n != 0 && n != mxGetM(prhs[1])) {
	mexErrMsgTxt("Dimension error (arg 2 and later).");
	return;
      }
      if (n != 0 && n != mxGetN(prhs[1])) {
		  mexErrMsgTxt("Dimension error (arg 2 and later).");
		  return;
      }
      n = mxGetN(prhs[1]);
      
      H = mxGetPr(prhs[1]);

#ifdef MX_COMPAT_32
      iH = mxGetIr(prhs[1]);
      kH = mxGetJc(prhs[1]);
#else
      iH_ = mxGetIr(prhs[1]);
      kH_ = mxGetJc(prhs[1]);

	  iH = (int*)malloc(mxGetNzmax(prhs[1])*sizeof(int)) ;
	  for (i=0; i<mxGetNzmax(prhs[1]); i++)
		  iH[i]=iH_[i] ;

	  kH = (int*)malloc((n+1)*sizeof(int)) ;
	  for (i=0; i<n+1; i++)
		  kH[i]=kH_[i] ;
#endif
	  
      nzH=myMalloc(n*sizeof(int)) ;
      for (i=0; i<n; i++)
		  nzH[i]=kH[i+1]-kH[i] ;
    }
  case 1:
	  if (mxGetM(prhs[0]) != 0 || mxGetN(prhs[0]) != 0) {
		  if (!mxIsNumeric(prhs[0]) || mxIsComplex(prhs[0]) 
			  ||  mxIsSparse(prhs[0])
	  || !mxIsDouble(prhs[0]) 
			  ||  mxGetN(prhs[0])!=1 ) {
			  mexErrMsgTxt("1st argument (cpenv) must be "
						   "a column vector.");
			  return;
      }
		  if (1 != mxGetM(prhs[0])) {
			  mexErrMsgTxt("Dimension error (arg 1).");
			  return;
		  }
		  cpenv = (long*) mxGetPr(prhs[0]);
	  }
  }
  /*if (display>3) */
	  fprintf(STD_OUT,"argument processing finished") ;
  
  /* Initialize the CPLEX environment */
  env = (CPXENVptr) cpenv[0] ;
  
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
  
  if (nlhs > 4 || nlhs < 1) {
	  mexErrMsgTxt("Usage: [x,lambda,how,p_qp] "
				   "= qp_solve(cpenv,H,c,A,b,l,u,neqcstr)");
	  return;
  }
  if (display>3) fprintf(STD_OUT, "(m=%i, n=%i, neq=%i) \n", m, n, neq) ;
  
  switch (nlhs) {
  case 4:
	  plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
	  p_qp = (long*) mxGetPr(plhs[3]);
  case 3:
	  /*    plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL);
			p_qpstat = mxGetPr(plhs[2]);*/
  case 2:
	  plhs[1] = mxCreateDoubleMatrix(m, 1, mxREAL);
	  lambda = mxGetPr(plhs[1]);
  case 1:
	  plhs[0] = mxCreateDoubleMatrix(n, 1, mxREAL);
	  x = mxGetPr(plhs[0]);
	  break;
  }
  if (display>2) fprintf(STD_OUT, "argument processing finished\n") ;
  
  if (strcmp(opt_method, "primal") &&  
	  strcmp(opt_method, "dual") &&
      strcmp(opt_method, "net") && 
	  strcmp(opt_method, "bar") &&
	  strcmp(opt_method, "sift") &&
	  strcmp(opt_method, "con") &&
	  strcmp(opt_method, "auto"))
	  mxErrMsgTxt("method \\in " 
				  "{'auto','primal','dual','bar','net','sift','con'}\n") ;

  if (strcmp(opt_method, "primal")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 1);
  else if (strcmp(opt_method, "dual")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 2);
  else if (strcmp(opt_method, "net")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 3);
  else if (strcmp(opt_method, "bar")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 4);
  else if (strcmp(opt_method, "sift")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 5);
  else if (strcmp(opt_method, "con")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 6);
  else if (strcmp(opt_method, "auto")==0)
	  status = CPXsetintparam (env, CPX_PARAM_QPMETHOD, 0);
  else 
	  status = 1 ;
  
  if ( status ) {
    fprintf (STD_OUT,"Failed to set QP method.\n");
    goto TERMINATE;
  }

  /* Create the problem */    
  if (display>2) fprintf(STD_OUT, "calling CPXcreateprob \n") ;
  qp = CPXcreateprob (env, &status, "xxx");
  if ( qp == NULL ) {
    fprintf (STD_OUT,"Failed to create subproblem\n");
    status = 1;
    goto TERMINATE;
  } 
  if (p_qp) *p_qp=(long) qp ;
  
  /* Copy network part of problem.  */    
  /*if (display>2) */
    fprintf(STD_OUT, "calling CPXcopylp (m=%i, n=%i) \n", m, n) ;
  status = CPXcopylp(env, qp, n, m, CPX_MIN, c, b, 
		     Sense, kA, nzA, iA, A, 
		     l, u, NULL);
  if ( status ) {
    fprintf (STD_OUT, "CPXcopylp failed.\n");
    goto TERMINATE;
  }
  
  /*if (display>2) */
    fprintf(STD_OUT, "calling CPXcopyquad \n") ;
  status = CPXcopyquad (env, qp, kH, nzH, iH, H);    
  
  if ( status ) {
    fprintf (STD_OUT, "CPXcopyquad failed.\n");
    goto TERMINATE;
  }
  
  /*if (display>2) */
    fprintf(STD_OUT, "calling optimizer 'bar'\n") ;
  status = CPXqpopt (env, qp);
  if (display>3)
    fprintf(STD_OUT, "CPXbaropt=%i\n", status) ;
  if ( status ) {
    fprintf (STD_OUT,"CPXbaropt failed.\n");
    goto TERMINATE;
  }
  
  if (display>2)
    fprintf(STD_OUT, "calling CPXsolution\n") ;
  status = CPXsolution (env, qp, &qpstat, &objval, x, lambda, NULL, NULL);
  if ( status ) {
    fprintf (STD_OUT,"CPXsolution failed.\n");
    goto TERMINATE;
  }
  
  if (display>1)
    fprintf (STD_OUT, "Solution status: %i,%s\n", qpstat, err_str[qpstat]);
  if (display>2)
    fprintf (STD_OUT, "Objective value %g\n", objval);
  
  if (nlhs >= 3) 
    if (qpstat==1)
      plhs[2] = mxCreateString(err_str[0]) ;
    else
      plhs[2] = mxCreateString(err_str[qpstat]) ;

  /*  if (nlhs >= 3) 
    if (qpstat==1)
      *p_qpstat = 0 ;
    else
    *p_qpstat = qpstat ;*/
  
 TERMINATE:
  if (status) {
    char  errmsg[1024];
    CPXgeterrorstring (env, status, errmsg);
    fprintf (STD_OUT, "%s", errmsg);
    if (nlhs >= 3) 
      plhs[2] = mxCreateString(errmsg) ;
    } ;
  if (nzA) myFree(nzA) ;
  if (nzH) myFree(nzH) ;
  if (Sense) myFree(Sense) ;

#ifndef MX_COMPAT_32
  if (iA) myFree(iA) ;
  if (kA) myFree(kA) ;
  if (iH) myFree(iH) ;
  if (kH) myFree(kH) ;
#endif
  
  if (!p_qp)
      {
	if ( qp != NULL ) {
	  if (display>2)
	    fprintf(STD_OUT, "calling CPXfreeprob\n") ;
	  status = CPXfreeprob (env, &qp);
	  if ( status ) {
	    fprintf (STD_OUT, "CPXfreeprob failed, error code %d.\n", status);
	  }
	}
      }
  return ;
}     
