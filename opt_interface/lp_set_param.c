/* lpex3.c, example of using CPXaddrows to solve a problem */

#include <stdio.h>
#include <stdlib.h>
#include "mex.h"

#include "cplex.h"

#define myMalloc CPXmalloc 
#define myFree CPXfree
#define STD_OUT stderr

struct param_info_
{
  const char *name ;
  const int code ;
} ;

#define NUM_PARAMS 106
struct param_info_ param_info[NUM_PARAMS]={
  {"CPX_PARAM_ADVIND",        1001},
  {"CPX_PARAM_AGGFILL",       1002},
  {"CPX_PARAM_AGGIND",        1003},
  {"CPX_PARAM_BASINTERVAL",   1004},
  {"CPX_PARAM_CFILEMUL",      1005},
  {"CPX_PARAM_CLOCKTYPE",     1006},
  {"CPX_PARAM_CRAIND",        1007},
  {"CPX_PARAM_DEPIND",        1008},
  {"CPX_PARAM_DPRIIND",       1009},
  {"CPX_PARAM_PRICELIM",      1010},
  {"CPX_PARAM_RIMREADLIM",    1011},
  {"CPX_PARAM_RIMNZREADLIM",  1012},
  {"CPX_PARAM_EPMRK",         1013},
  {"CPX_PARAM_EPOPT",         1014},
  {"CPX_PARAM_EPPER",         1015},
  {"CPX_PARAM_EPRHS",         1016},
  {"CPX_PARAM_FASTMIP",       1017},
  {"CPX_PARAM_IISIND",        1018},
  {"CPX_PARAM_SIMDISPLAY",    1019},
  {"CPX_PARAM_ITLIM",         1020},
  {"CPX_PARAM_ROWREADLIM",    1021},
  {"CPX_PARAM_NETFIND",       1022},
  {"CPX_PARAM_COLREADLIM",    1023},
  {"CPX_PARAM_NZREADLIM",     1024},
  {"CPX_PARAM_OBJLLIM",       1025},
  {"CPX_PARAM_OBJULIM",       1026},
  {"CPX_PARAM_PERIND",        1027},
  {"CPX_PARAM_PERLIM",        1028},
  {"CPX_PARAM_PPRIIND",       1029},
  {"CPX_PARAM_PREIND",        1030},
  {"CPX_PARAM_REINV",         1031},
  {"CPX_PARAM_REVERSEIND",    1032},
  {"CPX_PARAM_RFILEMUL",      1033},
  {"CPX_PARAM_SCAIND",        1034},
  {"CPX_PARAM_SCRIND",        1035},
  {"CPX_PARAM_SIMTHREADS",    1036},
  {"CPX_PARAM_SINGLIM",       1037},
  {"CPX_PARAM_SINGTOL",       1038},
  {"CPX_PARAM_TILIM",         1039},
  {"CPX_PARAM_XXXIND",        1041},
  {"CPX_PARAM_EFFSLACKIND",   1042},
  {"CPX_PARAM_PREDISP",       1043},
  {"CPX_PARAM_PREDUAL",       1044},
  {"CPX_PARAM_PREMEMFACT",    1045},
  {"CPX_PARAM_ROWGROWTH",     1046},
  {"CPX_PARAM_COLGROWTH",     1047},
  {"CPX_PARAM_NZGROWTH",      1048},
  {"CPX_PARAM_EPOPT_H",       1049},
  {"CPX_PARAM_EPRHS_H",       1050},
  {"CPX_PARAM_FLIPIND",       1051},
  {"CPX_PARAM_PREPASS",       1052},
  {"CPX_PARAM_LONGNAMEIND",   1053},
  {"CPX_PARAM_REDUCE",        1057},
  {"CPX_PARAM_LPMETHOD",      1062},
  {"CPX_PARAM_QPMETHOD",      1063},
  {"CPX_PARAM_WORKDIR",       1064},
  {"CPX_PARAM_WORKMEM",       1065},
  {"CPX_PARAM_PRECOMPRESS",   1066},
  {"CPX_PARAM_THREADS",       1067},
  {"CPX_PARAM_SIFTDISPLAY",   1076},
  {"CPX_PARAM_SIFTALG",       1077},
  {"CPX_PARAM_SIFTITLIM",     1078},
  {"CPX_PARAM_FINALFACTOR",   1080},
  {"CPX_PARAM_ALL_MIN",       1000},
  {"CPX_PARAM_ALL_MAX",       6000},
  {"CPX_PARAM_BARDSTART",     3001},
  {"CPX_PARAM_BAREPCOMP",     3002},
  {"CPX_PARAM_BARGROWTH",     3003},
  {"CPX_PARAM_BAROBJRNG",     3004},
  {"CPX_PARAM_BARPSTART",     3005},
  {"CPX_PARAM_BARVARUP",      3006},
  {"CPX_PARAM_BARALG",        3007},
  {"CPX_PARAM_BARUNROLL",     3008},
  {"CPX_PARAM_BARCOLNZ",      3009},
  {"CPX_PARAM_BARDISPLAY",    3010},
  {"CPX_PARAM_BARITLIM",      3012},
  {"CPX_PARAM_BARMAXCOR",     3013},
  {"CPX_PARAM_BARORDER",      3014},
  {"CPX_PARAM_BARROWSDEN",    3015},
  {"CPX_PARAM_BARTHREADS",    3016},
  {"CPX_PARAM_BARSTARTALG",   3017},
  {"CPX_PARAM_BARCROSSALG",   3018},
  {"CPX_PARAM_BAROOC",        3019},
  {"CPX_PARAM_BARQCPEPCOMP",  3020},
  {"CPX_PARAM_QPNZREADLIM",   4001},
  {"CPX_PARAM_QPNZGROWTH",    4002},
  {"CPX_PARAM_NETITLIM",      5001},
  {"CPX_PARAM_NETEPOPT",      5002},
  {"CPX_PARAM_NETEPRHS",      5003},
  {"CPX_PARAM_NETPPRIIND",    5004},
  {"CPX_PARAM_NETDISPLAY",    5005},
  {"CPX_PARAM_TRELIM",        2027},
  {"CPX_PARAM_NODEFILEIND",   2016},
  {"CPX_PARAM_HEURFREQ",      2031},
  {"CPX_PARAM_EPAGAP",        2008},
  {"CPX_PARAM_EPGAP",         2009},
  {"CPX_PARAM_HEURISTIC",     2011},
  {"CPX_PARAM_MIPHYBALG",     2043},
  {"CPX_PARAM_MIPORDTYPE",    2032},
  {"CPX_PARAM_RELAXPREIND",   2034},
  {"CPX_PARAM_MIPSTART",      2035},
  {"CPX_PARAM_NODESEL",       2018},
  {"CPX_PARAM_PROBE",         2042},
  {"CPX_PARAM_SUBALG",        2026},
  {"CPX_PARAM_VARSEL",        2028},
  {"CPX_PARAM_NODELIM",       2017},
} ;

#define NUM_DBLPARAMS 11
int dblParams[NUM_DBLPARAMS]={1014,1016,1065,3002,2027,2008,2009,2010,1015,5002,5003} ;
#define NUM_STRPARAMS 1
int strParams[NUM_STRPARAMS]={1064} ;

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]
)
{
  int display=0, i=0;
  long *lpenv=NULL ;
  CPXENVptr     env = NULL;
  int           status ;
  double value ;
  char param_name[128] ;
  int param_code=-1, dblfound=0, strfound=0 ;
  
  if (nrhs > 7 || nrhs < 1) {
    mexErrMsgTxt("Usage: [how] "
		 "= lp_set_param(lpenv, param_name, value, display)");
    return;
  }
  switch (nrhs) {
  case 4:
    if (mxGetM(prhs[3]) != 0 || mxGetN(prhs[3]) != 0) {
      if (!mxIsNumeric(prhs[3]) || mxIsComplex(prhs[3]) 
	  ||  mxIsSparse(prhs[3])
	  || !(mxGetM(prhs[3])==1 && mxGetN(prhs[3])==1)) {
	mexErrMsgTxt("4th argument (value) must be "
		     "an integer scalar.");
	return;
      }
      display = *mxGetPr(prhs[3]);
    }
  case 3:
    if (mxGetM(prhs[2]) != 0 || mxGetN(prhs[2]) != 0) {
      if (!mxIsNumeric(prhs[2]) || mxIsComplex(prhs[2]) 
	  ||  mxIsSparse(prhs[2])
	  || !(mxGetM(prhs[2])==1 && mxGetN(prhs[2])==1)) {
	mexErrMsgTxt("3rd argument (value) must be "
		     "an integer scalar.");
	return;
      }
      value = *mxGetPr(prhs[2]);
    }
  case 2:
    if (mxGetM(prhs[1]) != 0 || mxGetN(prhs[1]) != 0) {
      if (mxIsNumeric(prhs[1]) || mxIsComplex(prhs[1]) 
	  ||  mxIsSparse(prhs[1]) || !mxIsChar(prhs[1])
	  || !(mxGetM(prhs[1])==1) && mxGetN(prhs[1])>=1) {
	mexErrMsgTxt("2nd argument (param) must be "
		     "a string.");
	return;
      }
      mxGetString(prhs[1], param_name, 128);
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
  
  if (nlhs > 1 || nlhs < 1) {
    mexErrMsgTxt("Usage: [how] "
		 "= lp_set_param(lpenv,param_name,value,disp)");
    return;
  }
  if (display>2) fprintf(STD_OUT, "argument processing finished\n") ;

  /* Initialize the CPLEX environment */
  env = (CPXENVptr) lpenv[0] ;

  for (i=0; i<NUM_PARAMS; i++)
      if (strcmp(param_info[i].name, param_name)==0)
	  param_code=param_info[i].code ;

  if (display>3) 
    fprintf(STD_OUT, "(param=%s(%i), value=%f) \n", param_name, param_code, value) ;
  if (param_code==-1)
    mxErrMsgTxt("illegal parameter name") ;

  for (i=0; i<NUM_DBLPARAMS; i++)
    if (param_code==dblParams[i])
      dblfound=1 ;
  for (i=0; i<NUM_STRPARAMS; i++)
    if (param_code==strParams[i])
      strfound=1 ;
  if (dblfound==1) {
    if (display>2) 
      fprintf(STD_OUT, "calling CPXsetdblparam\n") ;
    status = CPXsetdblparam(env, param_code, value);
    if ( status ) {
      fprintf (STD_OUT, "CPXsetdblparam failed.\n");
      goto TERMINATE;
    } 
  } else if (strfound==1)
  {
	  fprintf(STD_OUT, "sorry not implemented\n") ;
  } else {
    if (display>2) 
      fprintf(STD_OUT, "calling CPXsetintparam\n") ;
    status = CPXsetintparam(env, param_code, (int)value);
    if ( status ) {
      fprintf (STD_OUT, "CPXsetintparam failed.\n");
      goto TERMINATE;
    }
  } ;

 TERMINATE:
  if (status) {
    char  errmsg[1024];
    CPXgeterrorstring (env, status, errmsg);
    fprintf (STD_OUT, "%s", errmsg);
    if (nlhs >= 1) 
      plhs[0] = mxCreateString(errmsg) ;
  } else
    if (nlhs >= 1) 
      plhs[0] = mxCreateString("OK") ;
  ;
  return ;
} 
