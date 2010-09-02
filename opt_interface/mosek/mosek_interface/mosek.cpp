/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.

 * Written (W) 2009 Fabio De Bona
 * Copyright (C) 2009 Max-Planck-Society
 */

#include <octave/oct.h>
#include <octave/ov.h>
#include <octave/ov-base-sparse.h>

#include <cmath>
#include <vector>
#include <string>
using namespace std;

/* Include the MOSEK interface header */ 
#include "mosek.h" 

//#define __DEBUG__


/* Small set of auxiliary functions */ 
#include "debugging_tools.h"

static int VERBOSITY =1 ;
 
static void MSKAPI printstr(void *handle, char str[]) { if (VERBOSITY>=1) printf("%s",str); } /* printstr */ 

bool is_nonzero(double val) {
   return ( fabs(val) > 1e-9 );
}

string get_problem_status_string(MSKprostae *pro_sta) {
   string pro;

   switch(*pro_sta) {
      case MSK_PRO_STA_DUAL_FEAS:
         pro = "problem is dual feasible";
         break;
      case MSK_PRO_STA_DUAL_INFEAS:
         pro = "problem is dual infeasible";
         break;
      case MSK_PRO_STA_ILL_POSED:
         pro = "problem is ill-posed. For example, it may be primal and dual feasible but have a positive duality gap";
         break;
      case MSK_PRO_STA_NEAR_DUAL_FEAS:
         pro = "problem is at least nearly dual feasible";
         break;
      case MSK_PRO_STA_NEAR_PRIM_AND_DUAL_FEAS:
         pro = "problem is at least nearly primal and dual feasible";
         break;
      case MSK_PRO_STA_NEAR_PRIM_FEAS:
         pro = "problem is at least nearly primal feasible";
         break;
      case MSK_PRO_STA_PRIM_AND_DUAL_FEAS:
         pro = "problem is primal and dual feasible";
         break;
      case MSK_PRO_STA_PRIM_AND_DUAL_INFEAS:
         pro = "problem is primal and dual infeasible";
         break;
      case MSK_PRO_STA_PRIM_FEAS:
         pro = "problem is primal feasible";
         break;
      case MSK_PRO_STA_PRIM_INFEAS:
         pro = "problem is primal infeasible";
         break;
      case MSK_PRO_STA_PRIM_INFEAS_OR_UNBOUNDED:
         pro = "problem is either primal infeasible or unbounded. This may occur for mixed integer problems";
         break;
      case MSK_PRO_STA_UNKNOWN:
         pro = "Unknown problem status";
         break;
      default:
         break;
   }
   return pro;
}

string get_solution_status_string(MSKsolstae *sol_sta) {
   string sol;

   switch(*sol_sta) {
      case MSK_SOL_STA_DUAL_FEAS:
         sol = "solution is dual feasible";
         break;
      case MSK_SOL_STA_DUAL_INFEAS_CER:
         sol = "solution is a certificate of dual infeasibility";
         break;
      case MSK_SOL_STA_INTEGER_OPTIMAL:
         sol =  "primal solution is integer optimal";
         break;
      case MSK_SOL_STA_NEAR_DUAL_FEAS:
         sol = "solution is nearly dual feasible";
         break;
      case MSK_SOL_STA_NEAR_DUAL_INFEAS_CER:
         sol = "solution is almost a certificate of dual infeasibility";
         break;
      case MSK_SOL_STA_NEAR_INTEGER_OPTIMAL:
         sol = "primal solution is near integer optimal";
         break;
      case MSK_SOL_STA_NEAR_OPTIMAL:
         sol = "solution is nearly optimal";
         break;
      case MSK_SOL_STA_NEAR_PRIM_AND_DUAL_FEAS:
         sol = "solution is nearly both primal and dual feasible";
         break;
      case MSK_SOL_STA_NEAR_PRIM_FEAS:
         sol = "solution is nearly primal feasible";
         break;
      case MSK_SOL_STA_NEAR_PRIM_INFEAS_CER:
         sol = "solution is almost a certificate of primal infeasibility";
         break;
      case MSK_SOL_STA_OPTIMAL:
         sol = "solution is optimal";
         break;
      case MSK_SOL_STA_PRIM_AND_DUAL_FEAS:
         sol = "solution is both primal and dual feasible";
         break;
      case MSK_SOL_STA_PRIM_FEAS:
         sol = "solution is primal feasible";
         break;
      case MSK_SOL_STA_PRIM_INFEAS_CER:
         sol = "solution is a certificate of primal infeasibility";
         break;
      case MSK_SOL_STA_UNKNOWN:
         sol = "Status of the solution is unknown";
         break;
      default:
         break;
   }
   return sol;
}

MSKboundkeye check_interval(MSKrealt a, MSKrealt b) {
   MSKboundkeye key;

   if ( ! std::isfinite(a) ) {

      if ( ! std::isfinite(b) )
         return MSK_BK_FR;

      return MSK_BK_UP;

   } else {

      if ( ! std::isfinite(b)  )
         return MSK_BK_LO;

      if ( fabs(a - b) < 1e-9 )
         return MSK_BK_FX;
      else 
         return MSK_BK_RA;
   }
   assert(false);
}


int SparseConvertMatrix(SparseMatrix &A, SparseMatrix &A_in,
				MSKlidxt** ptrb, MSKlidxt** ptre, MSKidxt** sub, MSKrealt** val) {
   int i,j;
	octave_idx_type A_nnz = A.nnz();
	octave_idx_type A_in_nnz = A_in.nnz();
   int num_nonzeros = A_nnz + A_in_nnz;
	dim_vector A_dims = A.dims();
   int num_rows = A_dims(0);
   int num_cols = A_dims(1);

	dim_vector A_in_dims = A_in.dims();
   int A_in_num_rows = A_in_dims(0);
   int A_in_num_cols = A_in_dims(1);

	int total_num_rows = num_rows + A_in_num_rows;

   *ptrb = new MSKlidxt[num_cols];
   *ptre = new MSKlidxt[num_cols];
   *sub  = new MSKidxt[num_nonzeros];
   *val  = new MSKrealt[num_nonzeros];

   //my_debug("A_nnz:%d,num_rows:%d,num_cols:%d\n",A_nnz,num_rows,num_cols);
   //my_debug("A_in_nnz:%d,num_rows:%d,num_cols:%d\n",A_in_nnz,A_in_num_rows,A_in_num_cols);

	// Attention!! In order to separate the constraint matrix filling of A and
	// A_in we use row order representation.  This is needed because A_in might
	// be empty.
   int idx = 0;
	// Add entries of the equality matrix A.
	for (j = 0; j < num_cols; j++) {
		(*ptrb)[j] = idx;
		if (A_nnz > 0) {
			for (i = A.cidx(j); i < A.cidx(j+1); i++) {
				//my_debug("non-zero element (%i,%i) is %f\n", 
		      //         A.ridx(i), j, A.data(i));
				(*val)[idx] = A.data(i);
				(*sub)[idx] = A.ridx(i);
				my_debug("non-zero element (%i,%i) is %f\n", 
				         (*sub)[idx], j, (*val)[idx]);
				idx++;
			}
		}
		if (A_in_nnz > 0) {
			for (i = A_in.cidx(j); i < A_in.cidx(j+1); i++) {
				 (*val)[idx] = A_in.data(i);
				 (*sub)[idx] = num_rows + A_in.ridx(i);
				 my_debug("non-zero element (%i,%i) is %f\n", 
				         (*sub)[idx], j, (*val)[idx]);
				 idx++ ;
			}
		}
		(*ptre)[j] = idx;
		my_debug("prtb/e @j: %d,%d,%d\n",(*ptrb)[j],(*ptre)[j],j);
	}
   return num_nonzeros;
}


int ConvertSparseSymmetricMatrix(SparseMatrix P, MSKidxt** subi,
											MSKidxt** subj, MSKrealt** val) {
	octave_idx_type nnz = P.nnz();
	dim_vector P_dims = P.dims();
   int num_rows = P_dims(0);
   int num_cols = P_dims(1);
   //my_debug2("size of P: (%d,%d)\n",num_rows,num_cols);

	vector<MSKidxt> subi_v(nnz,0);
	vector<MSKidxt> subj_v(nnz,0);
	vector<MSKrealt> val_v(nnz,0);
	int idx = 0;
	for (int j = 0; j < num_cols; j++) {
		for (int i = P.cidx(j); i < P.cidx(j+1); i++) {
			if(P.ridx(i) < j)
				continue;

			my_debug("non-zero element (%i,%i) is %f\n", 
			         P.ridx(i), j, P.data(i));
			
			subi_v[idx] = P.ridx(i);
			subj_v[idx] = j;
			val_v[idx] = P.data(i);
			idx++;
		}
	}
	nnz = idx;
	subi_v.resize(nnz);
	subj_v.resize(nnz);
	val_v.resize(nnz);
   *subi = new MSKidxt[nnz];
   *subj = new MSKidxt[nnz];
   *val  = new MSKrealt[nnz];
	for(int idx = 0; idx < nnz; idx++) {
		(*subi)[idx] = subi_v[idx];
		(*subj)[idx] = subj_v[idx];
		(*val)[idx]  = val_v[idx];
	}
   return nnz;
}

int ConvertSymmetricMatrix(Matrix P, MSKidxt** subi,
											MSKidxt** subj, MSKrealt** val) {
	dim_vector P_dims = P.dims();

   int num_nonzeros =  (P_dims(0)*(P_dims(0)+1)) / 2;

   *subi = new MSKidxt[num_nonzeros];
   *subj = new MSKidxt[num_nonzeros];
   *val  = new MSKrealt[num_nonzeros];

   int i,j,idx = 0;
   for(j=0; j<P_dims(1); j++) {
      for(i=0; i<P_dims(0); i++) {
         if (i<j)
            continue;

         (*subi)[idx] = i;
         (*subj)[idx] = j;
         (*val)[idx]  = P(i,j);
         //my_debug("%d %d %f / %d %d\n",i,j,M(i,j),(*subi)[idx],(*subj)[idx]);
         idx++;
   }}
   return idx;
}

/*
 *
 * qp (x0, P, q, A, b, lb, ub, A_lb, A_in, A_ub)
 * 
 * Explanation:
 *
 *  x0   - the initial solution
 *  P    - the quadratic term of the objective
 *  q    - the linear part of the objective
 *
 *  A    - the matrix of the equality constraints
 *  b    - rhs of the equality constraints
 *
 * lb    - lower bound on solution x ( lp <= x )
 * ub    - upper bound on solution x ( x <= ub )
 *
 * A_lb  - lower bound for inequality constraints
 * A_in  - Matrix representing inequality constraints
 * A_ub  - upper bound for inequality constraints
 *
 *
 * The MOSEK representation is equivalent
 *
 *
 */

DEFUN_DLD (__mosek_qp__, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{values}] =} __mosek__ (@var{args})\n\
Undocumented internal function.\n\
@end deftypefn")
{
  // The list of values to return.  See the declaration in oct-obj.h
  octave_value_list retval;

  MSKrealt primalobj;
  int num_threads=2 ;
  
  int nrhs = args.length ();

  my_debug("__mosek_qp__: nrhs is %d\n",nrhs);

  if (! (nrhs == 5 || nrhs == 7 || nrhs == 10 || nrhs == 11 || nrhs == 12) )
    {
      print_usage ();
      return retval;
    }

	my_debug("step1\n") ;

	Matrix _x0 = args(0).matrix_value();
	dim_vector x0_dims = _x0.dims();

	my_debug("step2\n") ;

	dim_vector P_dims = args(1).dims();
	SparseMatrix P = args(1).sparse_matrix_value();
	//octave_idx_type P_num_nonzeros = P.nnz();
	//fprintf(stdout, "%f,%d,%d,nnz=%i\n", P.data(0), P.ridx(0), P.cidx(0), P.nnz()) ;

   bool is_qp = true;
   if (P_dims(0) == 0 && P_dims(1) == 0)
      is_qp = false;

   /* get the sparse representation of the quadratic term of the objective */
   MSKidxt *P_subi = NULL ;
   MSKidxt *P_subj = NULL ;
   MSKrealt  *P_val = NULL ;
	
	int P_num_nonzeros = 0;
   if (is_qp) {
		//P_num_nonzeros = ConvertSymmetricMatrix(P, &P_subi, &P_subj, &P_val) ;        
		P_num_nonzeros = ConvertSparseSymmetricMatrix(P, &P_subi, &P_subj, &P_val) ;        
		my_debug("Matrix P: \n");
		print_symmetric(P_subi, P_subj, P_val, P_num_nonzeros);
	}

   /* a linear term q has to be given always */ 
   Matrix  _q = args(2).matrix_value();
   dim_vector q_dims = _q.dims();
   MSKintt num_variables = q_dims(0);  

	// Extract sparse information of equality constraint matrix A.
	SparseMatrix A = args(3).sparse_matrix_value();
	octave_idx_type A_num_nonzeros = A.nnz() ;
	//fprintf(stdout, "%e,%i,%i,nnz=%i\n", A.data(0), A.ridx(0), A.cidx(0), A_num_nonzeros);

   dim_vector A_dims = args(3).dims();
   MSKintt num_eq_constraints = A_dims(0);

   Matrix  _b = args(4).matrix_value();
   dim_vector b_dims = _b.dims();

	// Create & initialize C and octave solution vectors.
   double *xx = new double[num_variables];
   Matrix primal_sol (num_variables, 1);

   int idx;
   // Linear term of the objective.
   MSKrealt *q = new MSKrealt[num_variables];

   // Bounds of the variables.
   MSKrealt *blx     = new MSKrealt[num_variables];
   MSKrealt *bux     = new MSKrealt[num_variables];
   MSKboundkeye *bkx = new MSKboundkeye[num_variables];

   my_debug("num_variables: %d\n", num_variables);

   MSKboundkeye variable_bound_key = MSK_BK_FR;

   // Initialize bound keys and copy objective.
   for(idx=0; idx<num_variables; idx++) {
      bkx[idx] = variable_bound_key;
      blx[idx] = -MSK_INFINITY;
      bux[idx] =  MSK_INFINITY;
      // Set linear term of the objective.
      q[idx] = _q(idx);
   }

   if ( nrhs > 5 ) {
      Matrix lb = args(5).matrix_value();
      Matrix ub = args(6).matrix_value();

      for(idx=0; idx<num_variables; idx++) {
         blx[idx] = lb(idx);
         bux[idx] = ub(idx);

         variable_bound_key = check_interval(blx[idx],bux[idx]);
         bkx[idx] = variable_bound_key;
      }
		my_debug("Variable bounds:\n");
		print_bounds(bkx,blx,bux,num_variables);
   }

   MSKintt num_ineq_constraints = 0;

	dim_vector A_in_dims;
   if ( nrhs > 7 ) {
      SparseMatrix A_in = args(8).sparse_matrix_value();
      dim_vector A_in_dims = A_in.dims();
      num_ineq_constraints = A_in_dims(0);
   }

   MSKintt num_constraints = num_eq_constraints+num_ineq_constraints;
   
   // Bounds of  constraints.
   MSKrealt *blc = new MSKrealt[num_constraints];
   MSKrealt *buc = new MSKrealt[num_constraints];
   MSKboundkeye *bkc = new MSKboundkeye [num_constraints];
   MSKboundkeye constraints_bound_key = MSK_BK_FR;
   
   // First we set the equality constraints bounds.
   for(idx=0; idx<num_eq_constraints; idx++) {
      blc[idx] = _b(idx);
      buc[idx] = _b(idx);
      constraints_bound_key = check_interval(blc[idx],buc[idx]);
      bkc[idx] = constraints_bound_key;
   }

   my_debug("DEBUG: after eqn contraints\n");
   my_debug("num_constraints: %d\n", num_constraints);

   // Then we set the inequality constraints bounds.
   if ( nrhs > 7 ) {
      Matrix A_lb = args(7).matrix_value();
      Matrix A_ub = args(9).matrix_value();

      for(idx=num_eq_constraints; idx<num_constraints; idx++) {
         blc[idx] = A_lb(idx-num_eq_constraints);
         buc[idx] = A_ub(idx-num_eq_constraints);

         constraints_bound_key = check_interval(blc[idx],buc[idx]);
         bkc[idx] = constraints_bound_key;
      }
   }
   my_debug("DEBUG: after ineqn contraints\n");
   my_debug("Constraint bounds:\n");
   print_bounds(bkc,blc,buc,num_constraints);

	// Get the sparse representation of the constraint matrices.
	MSKlidxt *A_ptrb = NULL;
	MSKlidxt *A_ptre = NULL;
	MSKidxt  *A_sub = NULL;
	MSKrealt *A_val = NULL;

	// Extract sparse information of inequality constraint matrix A_in.
	SparseMatrix A_in;
   if ( nrhs > 7 ) {
		A_in = args(8).sparse_matrix_value();
		octave_idx_type A_in_num_nonzeros = A_in.nnz() ;
		//fprintf(stdout, "%e,%i,%i,nnz=%i\n", A_in.data(0), A_in.ridx(0), A_in.cidx(0), A_in_num_nonzeros);
	}

	SparseConvertMatrix(
	// First the sparse representation of the equality constraint matrix A.
	A,
	// Then the sparse representation of the inequality constraint matrix A_in.
	A_in,
	// Then the new location of the combined constraint matrix A.
	&A_ptrb, &A_ptre, &A_sub, &A_val);

   my_debug("Matrix A: \n");
   print_sparse(A_ptrb,A_ptre,A_sub,A_val,num_variables,A_num_nonzeros);
   //return retval;

   // Some variables for the dual variables.
   int num_dual_variables = num_constraints ;
   double *y = new double[num_dual_variables];
   Matrix dual_sol (num_dual_variables, 1);

   string problem_status_str;
   string solution_status_str;

   /* start of mosek code */
   MSKenv_t    env = NULL;
   MSKtask_t   task = NULL;
   MSKrescodee res;

   if ( nrhs > 10 ) {
      Matrix num_threads_ = args(10).matrix_value();

	  dim_vector num_threads_dims = num_threads_.dims();
	  if (num_threads_dims(0)!=1 || num_threads_dims(1)!=1)
	  {
		  print_usage ();
		  return retval;
	  }
	  num_threads = num_threads_(0) ;
   }

   if ( nrhs > 11 ) {
      Matrix verbosity_ = args(11).matrix_value();

	  dim_vector verbosity_dims = verbosity_.dims();
	  if (verbosity_dims(0)!=1 || verbosity_dims(1)!=1)
	  {
		  print_usage ();
		  return retval;
	  }
	  VERBOSITY = verbosity_(0) ;
   }

   //my_debug("DEBUG: after init now mosek code begins\n");

   /* Create an environment */
   res = MSK_makeenv(&env, NULL,NULL,NULL,NULL);

   if ( res==MSK_RES_OK ) { 
      /* Directs the log stream to the 'printstr' function. */  
      MSK_linkfunctoenvstream(env, MSK_STREAM_LOG, NULL, printstr); 
   } 

   /* Initialize the environment */
   if (res == MSK_RES_OK)
      res = MSK_initenv(env);

   if ( res==MSK_RES_OK ) { 
    
      /* Create the optimization task. */  
      res = MSK_maketask(env,num_constraints,num_variables,&task);

	  MSK_putintparam(task, MSK_IPAR_INTPNT_NUM_THREADS, num_threads) ;
	  
      if ( res==MSK_RES_OK ) { 
         res = MSK_linkfunctotaskstream(task,MSK_STREAM_LOG,NULL,printstr);

         if ( res==MSK_RES_OK )
            res = MSK_inputdata(task, num_constraints, num_variables, num_constraints,num_variables, q, 0.0, A_ptrb, A_ptre, A_sub, A_val, bkc, blc, buc, bkx, blx, bux); 

         /* * The lower triangular part of the Q * matrix in the objective is specified. */
         if ( is_qp && res==MSK_RES_OK ) { 

            /* Input the Q for the objective. */  
            res = MSK_putqobj(task,P_num_nonzeros,P_subi,P_subj,P_val);
         }
         fflush(stdout);

         if ( res==MSK_RES_OK ) 
            res = MSK_optimize(task);
         
         // if solver was successful
         if ( res==MSK_RES_OK ) 
	   {
	     MSKprostae problem_status ;
	     MSKsolstae solution_status ;

	     res = MSK_getsolutionstatus (task,MSK_SOL_ITR,&problem_status,&solution_status);
	     
	     if ( res==MSK_RES_OK ) {
               //my_debug2("DEBUG: getsolutionstatus successful\n");
               problem_status_str = get_problem_status_string(&problem_status);
               solution_status_str = get_solution_status_string(&solution_status);
	       
               //my_debug2("DEBUG: %s\n",problem_status_str.c_str());
               //my_debug2("DEBUG: %s\n",solution_status_str.c_str());
	       
               res = MSK_getprimalobj (task, MSK_SOL_ITR, &primalobj);
	       
               if ( res==MSK_RES_OK ) {
		 //my_debug2("DEBUG: getprimalobj successful\n");
		 // fetch primal solution
		 MSK_getsolutionslice(task, MSK_SOL_ITR, MSK_SOL_ITEM_XX, 0, num_variables, xx);
		 //my_debug("Primal solution\n");
		 MSKidxt j;
		 for(j=0; j<num_variables; ++j) {
		   //my_debug("xx[%d]: %f\n",j,xx[j]);
		   primal_sol(j) = xx[j];
		 }
		 
		 // fetch dual solution
		 MSK_getsolutionslice(task, MSK_SOL_ITR, MSK_SOL_ITEM_XC, 0, num_dual_variables, y);
		 for(j=0; j<num_dual_variables; ++j) {
		   my_debug("y[%d]: %f\n",j,y[j]);
		   dual_sol(j) = y[j];
		 }
	       }}}}
      
      MSK_deletetask(&task);
   } 
   
   MSK_deleteenv(&env);

   delete[] bkx;
   delete[] blx;
   delete[] bux;

   delete[] bkc;
   delete[] blc;
   delete[] buc;

   if ( nrhs > 7 ) {
      delete[] A_ptrb;
      delete[] A_ptre; 
      delete[] A_sub;   
      delete[] A_val;    
   }

   if ( is_qp ) {
      delete[] P_subi;
      delete[] P_subj; 
      delete[] P_val;
   }

   delete[] q;
   delete[] xx;
   delete[] y;
   
   retval(0) = octave_value ( primal_sol );
   retval(1) = octave_value ( primalobj );
   retval(2) = octave_value ( dual_sol );
   retval(3) = octave_value ( problem_status_str );
   retval(4) = octave_value ( solution_status_str );
   return retval;
}
