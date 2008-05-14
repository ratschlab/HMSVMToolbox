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
 *   mex compute_score_matrix.cpp score_plif_struct.cpp -I/fml/ag-raetsch/share/software/matlab/extern/include 
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
  const int L = X_N;                      // length of the given example
  const int n_states = scr_N;
  double *pp = new double[L*n_states];
  for (int i=0; i<L*n_states; ++i)
    pp[i] = 0.0;
  // scores for real-valued features
  for (int pos=0; pos<L; ++pos) {         // for all positions in given example
    for (int f=0; f<scr_M; ++f) {         // for all features
      for (int s=0; s<n_states; ++s) {    // for all states
	const int scr_idx = s*scr_M+f;
	assert(scr_ptr[scr_idx].feat_idx==f+1);
	const int pp_idx = pos*n_states+s;
	const int X_idx = pos*X_M+f;
	
	pp[pp_idx] += lookup_score_plif(&scr_ptr[scr_idx], X_ptr[X_idx]);
      }
    }
  }
  	
  // prepare return values
//  fprintf(stderr, "writing return values...\n");
  plhs[0] = mxCreateDoubleMatrix(n_states, L, mxREAL);
  double *ret0 = mxGetPr(plhs[0]);
  memcpy(ret0, pp, mxGetM(plhs[0])*mxGetN(plhs[0])*mxGetElementSize(plhs[0]));
  
  delete_score_plif_struct_matrix(scr_ptr, scr_M, scr_N);
  delete[] pp;
}
