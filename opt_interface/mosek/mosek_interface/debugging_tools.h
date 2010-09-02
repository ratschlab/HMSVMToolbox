#ifndef __DEBUGING_TOOLS_H__
#define __DEBUGING_TOOLS_H__

inline int my_debug2(char *format, ...) {
   va_list args;
   va_start(args, format);
   int r = vprintf(format, args);
   va_end(args);
   return r;
}

//#define __DEBUG__

#ifdef __DEBUG__
inline int my_debug(char *format, ...) {
   va_list args;
   va_start(args, format);
   int r = vprintf(format, args);
   va_end(args);
   return r;
}

void print_sparse_col_order(MSKlidxt *ptrb, MSKlidxt *ptre, MSKidxt *sub, MSKrealt *val, int num_cols, int num_nonzeros) {
   int j;
   printf("ptrb:\n");
   for(j=0; j<num_cols; j++) {
      printf("%d ",ptrb[j]);
   }
   printf("\n");

   printf("ptre:\n");
   for(j=0; j<num_cols; j++) {
      printf("%d ",ptre[j]);
   }
   printf("\n");

   printf("sub:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%d ",sub[j]);
   }
   printf("\n");

   printf("val:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%f ",val[j]);
   }
   printf("\n");
}

void print_sparse(MSKlidxt *ptrb, MSKlidxt *ptre, MSKidxt *sub, MSKrealt *val, int num_rows, int num_nonzeros) {
   int j;
   printf("ptrb:\n");
   for(j=0; j<num_rows; j++) {
      printf("%d ",ptrb[j]);
   }
   printf("\n");

   printf("ptre:\n");
   for(j=0; j<num_rows; j++) {
      printf("%d ",ptre[j]);
   }
   printf("\n");

   printf("sub:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%d ",sub[j]);
   }
   printf("\n");

   printf("val:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%f ",val[j]);
   }
   printf("\n");
}

void print_bounds(MSKboundkeye* bkx, MSKrealt* blx, MSKrealt* bux, MSKintt num_variables) {
   int j;
   printf("keys:\n");
   for(j=0; j<num_variables; j++) {
      printf("%d ",bkx[j]);
   }
   printf("\n");

   printf("lower bounds:\n");
   for(j=0; j<num_variables; j++) {
      printf("%f ",blx[j]);
   }
   printf("\n");

   printf("upper bounds:\n");
   for(j=0; j<num_variables; j++) {
      printf("%f ",bux[j]);
   }
   printf("\n");
}


void print_symmetric(MSKidxt* subi, MSKidxt* subj, MSKrealt *val, MSKintt num_nonzeros) {
   int j;
   printf("subi:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%d ",subi[j]);
   }
   printf("\n");

   printf("subj:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%d ",subj[j]);
   }
   printf("\n");

   printf("val:\n");
   for(j=0; j<num_nonzeros; j++) {
      printf("%f ",val[j]);
   }
   printf("\n");
}

#else
inline int my_debug(char *format, ...) {}

inline void print_sparse(MSKlidxt *ptrb, MSKlidxt *ptre, MSKidxt *sub, MSKrealt *val, int num_rows, int num_nonzeros) {}

inline void print_bounds(MSKboundkeye* bkx, MSKrealt* blx, MSKrealt* bux, MSKintt num_variables) {}

inline void print_symmetric(MSKidxt* subi, MSKidxt* subj, MSKrealt *val, MSKintt num_nonzeros) {}
#endif // __DEBUG__

#endif //  __DEBUGING_TOOLS_H__
