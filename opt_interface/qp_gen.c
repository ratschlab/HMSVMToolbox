/* lpex3.c, example of using CPXaddrows to solve a problem */

#include <stdio.h>
#include <stdlib.h>
#include "mex.h"

#include "cplex.h"

#define myMalloc CPXmalloc 
#define myFree CPXfree 
#define STD_OUT stderr

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]
)
{
  int i, j;
  double *c=NULL, *b=NULL, *A=NULL, *H=NULL,
    *l=NULL, *u=NULL, *x=NULL, *lambda=NULL ;
  int *iA=NULL, *kA=NULL, *nzA=NULL ;
  int *iH=NULL, *kH=NULL, *nzH=NULL ;
  int neq=0, m=0, n=0, display=0;
  long *cpenv=NULL, *p_qp=NULL;
  char *Sense=NULL ;
#ifndef MX_COMPAT_32
  long *iA_=NULL, *kA_=NULL ;
  long *iH_=NULL, *kH_=NULL ;
#endif 

  if (nrhs > 9 || nrhs < 1) {
    mexErrMsgTxt("Usage: [p_qp,how] "
		 "= qp_solve(cpenv,Q,c,A,b,l,u,neq,disp)");
    return;
  }
  switch (nrhs) {
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
  
  if (nlhs > 2 || nlhs < 1) {
    mexErrMsgTxt("Usage: [p_qp,how] "
		 "= qp_gen(cpenv,H,c,A,b,l,u,neqcstr,disp)");
    return;
  }
  if (display>3) fprintf(STD_OUT, "(m=%i, n=%i, neq=%i) \n", m, n, neq) ;

  switch (nlhs) {
  case 2:
  case 1:
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    p_qp = (long*) mxGetPr(plhs[0]);
  }
  if (display>2) fprintf(STD_OUT, "argument processing finished\n") ;
  {
    CPXENVptr     env = NULL;
    CPXLPptr      qp = NULL;

    int           status, qpstat;
    double        objval;

    /* Initialize the CPLEX environment */
    env = (CPXENVptr) cpenv[0] ;

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
    if (display>2) 
      fprintf(STD_OUT, "calling CPXcopylp (m=%i, n=%i) \n", m, n) ;
    status = CPXcopylp(env, qp, n, m, CPX_MIN, c, b, 
		       Sense, kA, nzA, iA, A, 
		       l, u, NULL);
    if ( status ) {
      fprintf (STD_OUT, "CPXcopylp failed.\n");
      goto TERMINATE;
    }

    if (display>2) 
      fprintf(STD_OUT, "calling CPXcopyquad \n") ;
    status = CPXcopyquad (env, qp, kH, nzH, iH, H);    
    
    if ( status ) {
      fprintf (STD_OUT, "CPXcopyquad failed.\n");
      goto TERMINATE;
    }

 TERMINATE:
    if (status) {
      char  errmsg[1024];
      CPXgeterrorstring (env, status, errmsg);
      fprintf (stderr, "%s", errmsg);
      if (nlhs >= 2) 
	plhs[1] = mxCreateString(errmsg) ;
    } else
      if (nlhs >= 2) 
	plhs[1] = mxCreateString("OK") ;

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
} 
