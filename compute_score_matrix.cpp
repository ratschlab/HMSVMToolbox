/*
 * COMPUTE_SCORE_MATRIX.CPP	
 *	    computes a matrix for score cumulation during decoding 
 *          given a training example X, and feature scoring functions score_fcts
 *
 * The calling syntax is:
 *
 *		[scr_matrix] = compute_score_matrix(X,score_fcts) 
 *
 * Compile using
 *   mex compute_score_matrix.cpp score_plif_struct.cpp 
 *
 * Written by Gunnar Raetsch & Georg Zeller, MPI Tuebingen, Germany
 */

#include <assert.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "mex.h"
#include "score_plif_struct.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {		  

  if(nrhs != 2) {
    mexErrMsgTxt("expected 2 input arguments:\n [scr_matrix] = compute_score_matrix(X,score_fcts)\n");
    return;
  }
  
  if(nlhs != 1) {
    mexErrMsgTxt("expected 1 output argument\n [scr_matrix] = compute_score_matrix(X,score_fcts)\n");
    return;
  }
  
//  fprintf(stderr, "reading input arguments...\n");
  
  // read input arguments
  int arg = 0;

  double *X_ptr;
  const int X_M = mxGetM(prhs[arg]);
  const int X_N = mxGetN(prhs[arg]);
  X_ptr = mxGetPr(prhs[arg]);
  ++arg;
  
//  fprintf(stderr, "finished reading matrix data\n");
	
  score_plif_struct *scr_ptr;
  int scr_M = 0; int scr_N = 0;
  scr_ptr = read_score_plif_struct(prhs[arg], scr_M, scr_N);
  ++arg;
  
  // compute scores along the possible paths for X
  const double INF = INFINITY;
  const int L = X_N;                      // length of the given example
  const int n_states = scr_N;
  plhs[0] = mxCreateDoubleMatrix(n_states, L, mxREAL);
  double *pp = mxGetPr(plhs[0]);
  // will already be initialized to 0.0 by mxCreateDoubleMatrix

  // scores for real-valued features
  for (int pos=0; pos<L; ++pos) {         // for all positions in given example
    for (int f=0; f<scr_M; ++f) {         // for all features
      for (int s=0; s<n_states; ++s) {    // for all states
	const int scr_idx = s*scr_M+f;
	assert(scr_ptr[scr_idx].feat_idx==f+1);
	const int pp_idx = pos*n_states+s;
	const int X_idx = pos*X_M+f;
	
	//	if (X_ptr[X_idx] > -INF)
	pp[pp_idx] += lookup_score_plif(&scr_ptr[scr_idx], X_ptr[X_idx]);
	//	else
	//	  pp[pp_idx] = -INF;
      }
    }
  }
  	
  // clean up
  delete_score_plif_struct_matrix(scr_ptr, scr_M, scr_N);
}
