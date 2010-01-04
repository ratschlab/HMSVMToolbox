unit mosek;
(*
 *
 *   Copyright: $$copyright
 *   File:      mosek.pas
 *
 *)
{$X+}{$Z4}{$A8}

interface

const
  mosekDLLFile = 'mosek5_0.dll';


(************************************************************)
(**  CONSTANTS AND ENUMS                                   **)
(************************************************************)
(* Solve primal or dual form *)
const
  MSK_SOLVE_PRIMAL                     = 1;
  MSK_SOLVE_DUAL                       = 2;
  MSK_SOLVE_FREE                       = 0;

(* Constraint or variable access modes *)
type
  MSKaccmode =
  (
    MSK_ACC_VAR                        = 0,
    MSK_ACC_CON                        = 1
  );

(* Sensitivity types *)
const
  MSK_SENSITIVITY_TYPE_OPTIMAL_PARTITION = 1;
  MSK_SENSITIVITY_TYPE_BASIS           = 0;

(* Interpretation of quadratic terms in MPS files *)
const
  MSK_Q_READ_ADD                       = 0;
  MSK_Q_READ_DROP_LOWER                = 1;
  MSK_Q_READ_DROP_UPPER                = 2;

(* Integer parameters *)
type
  MSKiparam =
  (
    MSK_IPAR_ALLOC_ADD_QNZ             = 0,
    MSK_IPAR_BI_CLEAN_OPTIMIZER        = 1,
    MSK_IPAR_BI_IGNORE_MAX_ITER        = 2,
    MSK_IPAR_BI_IGNORE_NUM_ERROR       = 3,
    MSK_IPAR_BI_MAX_ITERATIONS         = 4,
    MSK_IPAR_CACHE_SIZE_L1             = 5,
    MSK_IPAR_CACHE_SIZE_L2             = 6,
    MSK_IPAR_CHECK_CONVEXITY           = 7,
    MSK_IPAR_CHECK_CTRL_C              = 8,
    MSK_IPAR_CHECK_TASK_DATA           = 9,
    MSK_IPAR_CONCURRENT_NUM_OPTIMIZERS = 10,
    MSK_IPAR_CONCURRENT_PRIORITY_DUAL_SIMPLEX = 11,
    MSK_IPAR_CONCURRENT_PRIORITY_FREE_SIMPLEX = 12,
    MSK_IPAR_CONCURRENT_PRIORITY_INTPNT = 13,
    MSK_IPAR_CONCURRENT_PRIORITY_PRIMAL_SIMPLEX = 14,
    MSK_IPAR_CPU_TYPE                  = 15,
    MSK_IPAR_DATA_CHECK                = 16,
    MSK_IPAR_FEASREPAIR_OPTIMIZE       = 17,
    MSK_IPAR_FLUSH_STREAM_FREQ         = 18,
    MSK_IPAR_INFEAS_GENERIC_NAMES      = 19,
    MSK_IPAR_INFEAS_PREFER_PRIMAL      = 20,
    MSK_IPAR_INFEAS_REPORT_AUTO        = 21,
    MSK_IPAR_INFEAS_REPORT_LEVEL       = 22,
    MSK_IPAR_INTPNT_BASIS              = 23,
    MSK_IPAR_INTPNT_DIFF_STEP          = 24,
    MSK_IPAR_INTPNT_FACTOR_DEBUG_LVL   = 25,
    MSK_IPAR_INTPNT_FACTOR_METHOD      = 26,
    MSK_IPAR_INTPNT_MAX_ITERATIONS     = 27,
    MSK_IPAR_INTPNT_MAX_NUM_COR        = 28,
    MSK_IPAR_INTPNT_MAX_NUM_REFINEMENT_STEPS = 29,
    MSK_IPAR_INTPNT_NUM_THREADS        = 30,
    MSK_IPAR_INTPNT_OFF_COL_TRH        = 31,
    MSK_IPAR_INTPNT_ORDER_METHOD       = 32,
    MSK_IPAR_INTPNT_REGULARIZATION_USE = 33,
    MSK_IPAR_INTPNT_SCALING            = 34,
    MSK_IPAR_INTPNT_SOLVE_FORM         = 35,
    MSK_IPAR_INTPNT_STARTING_POINT     = 36,
    MSK_IPAR_LICENSE_ALLOW_OVERUSE     = 37,
    MSK_IPAR_LICENSE_CACHE_TIME        = 38,
    MSK_IPAR_LICENSE_CHECK_TIME        = 39,
    MSK_IPAR_LICENSE_DEBUG             = 40,
    MSK_IPAR_LICENSE_PAUSE_TIME        = 41,
    MSK_IPAR_LICENSE_SUPPRESS_EXPIRE_WRNS = 42,
    MSK_IPAR_LICENSE_WAIT              = 43,
    MSK_IPAR_LOG                       = 44,
    MSK_IPAR_LOG_BI                    = 45,
    MSK_IPAR_LOG_BI_FREQ               = 46,
    MSK_IPAR_LOG_CONCURRENT            = 47,
    MSK_IPAR_LOG_CUT_SECOND_OPT        = 48,
    MSK_IPAR_LOG_FACTOR                = 49,
    MSK_IPAR_LOG_FEASREPAIR            = 50,
    MSK_IPAR_LOG_FILE                  = 51,
    MSK_IPAR_LOG_HEAD                  = 52,
    MSK_IPAR_LOG_INFEAS_ANA            = 53,
    MSK_IPAR_LOG_INTPNT                = 54,
    MSK_IPAR_LOG_MIO                   = 55,
    MSK_IPAR_LOG_MIO_FREQ              = 56,
    MSK_IPAR_LOG_NONCONVEX             = 57,
    MSK_IPAR_LOG_OPTIMIZER             = 58,
    MSK_IPAR_LOG_ORDER                 = 59,
    MSK_IPAR_LOG_PARAM                 = 60,
    MSK_IPAR_LOG_PRESOLVE              = 61,
    MSK_IPAR_LOG_RESPONSE              = 62,
    MSK_IPAR_LOG_SENSITIVITY           = 63,
    MSK_IPAR_LOG_SENSITIVITY_OPT       = 64,
    MSK_IPAR_LOG_SIM                   = 65,
    MSK_IPAR_LOG_SIM_FREQ              = 66,
    MSK_IPAR_LOG_SIM_MINOR             = 67,
    MSK_IPAR_LOG_SIM_NETWORK_FREQ      = 68,
    MSK_IPAR_LOG_STORAGE               = 69,
    MSK_IPAR_LP_WRITE_IGNORE_INCOMPATIBLE_ITEMS = 70,
    MSK_IPAR_MAX_NUM_WARNINGS          = 71,
    MSK_IPAR_MAXNUMANZ_DOUBLE_TRH      = 72,
    MSK_IPAR_MIO_BRANCH_DIR            = 73,
    MSK_IPAR_MIO_BRANCH_PRIORITIES_USE = 74,
    MSK_IPAR_MIO_CONSTRUCT_SOL         = 75,
    MSK_IPAR_MIO_CONT_SOL              = 76,
    MSK_IPAR_MIO_CUT_LEVEL_ROOT        = 77,
    MSK_IPAR_MIO_CUT_LEVEL_TREE        = 78,
    MSK_IPAR_MIO_FEASPUMP_LEVEL        = 79,
    MSK_IPAR_MIO_HEURISTIC_LEVEL       = 80,
    MSK_IPAR_MIO_KEEP_BASIS            = 81,
    MSK_IPAR_MIO_LOCAL_BRANCH_NUMBER   = 82,
    MSK_IPAR_MIO_MAX_NUM_BRANCHES      = 83,
    MSK_IPAR_MIO_MAX_NUM_RELAXS        = 84,
    MSK_IPAR_MIO_MAX_NUM_SOLUTIONS     = 85,
    MSK_IPAR_MIO_MODE                  = 86,
    MSK_IPAR_MIO_NODE_OPTIMIZER        = 87,
    MSK_IPAR_MIO_NODE_SELECTION        = 88,
    MSK_IPAR_MIO_PRESOLVE_AGGREGATE    = 89,
    MSK_IPAR_MIO_PRESOLVE_USE          = 90,
    MSK_IPAR_MIO_ROOT_OPTIMIZER        = 91,
    MSK_IPAR_MIO_STRONG_BRANCH         = 92,
    MSK_IPAR_NONCONVEX_MAX_ITERATIONS  = 93,
    MSK_IPAR_OBJECTIVE_SENSE           = 94,
    MSK_IPAR_OPF_MAX_TERMS_PER_LINE    = 95,
    MSK_IPAR_OPF_WRITE_HEADER          = 96,
    MSK_IPAR_OPF_WRITE_HINTS           = 97,
    MSK_IPAR_OPF_WRITE_PARAMETERS      = 98,
    MSK_IPAR_OPF_WRITE_PROBLEM         = 99,
    MSK_IPAR_OPF_WRITE_SOL_BAS         = 100,
    MSK_IPAR_OPF_WRITE_SOL_ITG         = 101,
    MSK_IPAR_OPF_WRITE_SOL_ITR         = 102,
    MSK_IPAR_OPF_WRITE_SOLUTIONS       = 103,
    MSK_IPAR_OPTIMIZER                 = 104,
    MSK_IPAR_PARAM_READ_CASE_NAME      = 105,
    MSK_IPAR_PARAM_READ_IGN_ERROR      = 106,
    MSK_IPAR_PRESOLVE_ELIM_FILL        = 107,
    MSK_IPAR_PRESOLVE_ELIMINATOR_USE   = 108,
    MSK_IPAR_PRESOLVE_LEVEL            = 109,
    MSK_IPAR_PRESOLVE_LINDEP_USE       = 110,
    MSK_IPAR_PRESOLVE_LINDEP_WORK_LIM  = 111,
    MSK_IPAR_PRESOLVE_USE              = 112,
    MSK_IPAR_READ_ADD_ANZ              = 113,
    MSK_IPAR_READ_ADD_CON              = 114,
    MSK_IPAR_READ_ADD_CONE             = 115,
    MSK_IPAR_READ_ADD_QNZ              = 116,
    MSK_IPAR_READ_ADD_VAR              = 117,
    MSK_IPAR_READ_ANZ                  = 118,
    MSK_IPAR_READ_CON                  = 119,
    MSK_IPAR_READ_CONE                 = 120,
    MSK_IPAR_READ_DATA_COMPRESSED      = 121,
    MSK_IPAR_READ_DATA_FORMAT          = 122,
    MSK_IPAR_READ_KEEP_FREE_CON        = 123,
    MSK_IPAR_READ_LP_DROP_NEW_VARS_IN_BOU = 124,
    MSK_IPAR_READ_LP_QUOTED_NAMES      = 125,
    MSK_IPAR_READ_MPS_FORMAT           = 126,
    MSK_IPAR_READ_MPS_KEEP_INT         = 127,
    MSK_IPAR_READ_MPS_OBJ_SENSE        = 128,
    MSK_IPAR_READ_MPS_QUOTED_NAMES     = 129,
    MSK_IPAR_READ_MPS_RELAX            = 130,
    MSK_IPAR_READ_MPS_WIDTH            = 131,
    MSK_IPAR_READ_Q_MODE               = 132,
    MSK_IPAR_READ_QNZ                  = 133,
    MSK_IPAR_READ_TASK_IGNORE_PARAM    = 134,
    MSK_IPAR_READ_VAR                  = 135,
    MSK_IPAR_SENSITIVITY_ALL           = 136,
    MSK_IPAR_SENSITIVITY_OPTIMIZER     = 137,
    MSK_IPAR_SENSITIVITY_TYPE          = 138,
    MSK_IPAR_SIM_DEGEN                 = 139,
    MSK_IPAR_SIM_DUAL_CRASH            = 140,
    MSK_IPAR_SIM_DUAL_RESTRICT_SELECTION = 141,
    MSK_IPAR_SIM_DUAL_SELECTION        = 142,
    MSK_IPAR_SIM_HOTSTART              = 143,
    MSK_IPAR_SIM_MAX_ITERATIONS        = 144,
    MSK_IPAR_SIM_MAX_NUM_SETBACKS      = 145,
    MSK_IPAR_SIM_NETWORK_DETECT        = 146,
    MSK_IPAR_SIM_NETWORK_DETECT_HOTSTART = 147,
    MSK_IPAR_SIM_NETWORK_DETECT_METHOD = 148,
    MSK_IPAR_SIM_NON_SINGULAR          = 149,
    MSK_IPAR_SIM_PRIMAL_CRASH          = 150,
    MSK_IPAR_SIM_PRIMAL_RESTRICT_SELECTION = 151,
    MSK_IPAR_SIM_PRIMAL_SELECTION      = 152,
    MSK_IPAR_SIM_REFACTOR_FREQ         = 153,
    MSK_IPAR_SIM_SAVE_LU               = 154,
    MSK_IPAR_SIM_SCALING               = 155,
    MSK_IPAR_SIM_SOLVE_FORM            = 156,
    MSK_IPAR_SIM_STABILITY_PRIORITY    = 157,
    MSK_IPAR_SIM_SWITCH_OPTIMIZER      = 158,
    MSK_IPAR_SOL_FILTER_KEEP_BASIC     = 159,
    MSK_IPAR_SOL_FILTER_KEEP_RANGED    = 160,
    MSK_IPAR_SOL_QUOTED_NAMES          = 161,
    MSK_IPAR_SOL_READ_NAME_WIDTH       = 162,
    MSK_IPAR_SOL_READ_WIDTH            = 163,
    MSK_IPAR_SOLUTION_CALLBACK         = 164,
    MSK_IPAR_WARNING_LEVEL             = 165,
    MSK_IPAR_WRITE_BAS_CONSTRAINTS     = 166,
    MSK_IPAR_WRITE_BAS_HEAD            = 167,
    MSK_IPAR_WRITE_BAS_VARIABLES       = 168,
    MSK_IPAR_WRITE_DATA_COMPRESSED     = 169,
    MSK_IPAR_WRITE_DATA_FORMAT         = 170,
    MSK_IPAR_WRITE_DATA_PARAM          = 171,
    MSK_IPAR_WRITE_FREE_CON            = 172,
    MSK_IPAR_WRITE_GENERIC_NAMES       = 173,
    MSK_IPAR_WRITE_GENERIC_NAMES_IO    = 174,
    MSK_IPAR_WRITE_INT_CONSTRAINTS     = 175,
    MSK_IPAR_WRITE_INT_HEAD            = 176,
    MSK_IPAR_WRITE_INT_VARIABLES       = 177,
    MSK_IPAR_WRITE_LP_LINE_WIDTH       = 178,
    MSK_IPAR_WRITE_LP_QUOTED_NAMES     = 179,
    MSK_IPAR_WRITE_LP_STRICT_FORMAT    = 180,
    MSK_IPAR_WRITE_LP_TERMS_PER_LINE   = 181,
    MSK_IPAR_WRITE_MPS_INT             = 182,
    MSK_IPAR_WRITE_MPS_OBJ_SENSE       = 183,
    MSK_IPAR_WRITE_MPS_QUOTED_NAMES    = 184,
    MSK_IPAR_WRITE_MPS_STRICT          = 185,
    MSK_IPAR_WRITE_PRECISION           = 186,
    MSK_IPAR_WRITE_SOL_CONSTRAINTS     = 187,
    MSK_IPAR_WRITE_SOL_HEAD            = 188,
    MSK_IPAR_WRITE_SOL_VARIABLES       = 189,
    MSK_IPAR_WRITE_TASK_INC_SOL        = 190,
    MSK_IPAR_WRITE_XML_MODE            = 191,
    MSK_IPAR_MIO_PRESOLVE_PROBING      = 192
  );

(* Solution status keys *)
type
  MSKsolsta =
  (
    MSK_SOL_STA_UNKNOWN                = 0,
    MSK_SOL_STA_OPTIMAL                = 1,
    MSK_SOL_STA_PRIM_FEAS              = 2,
    MSK_SOL_STA_DUAL_FEAS              = 3,
    MSK_SOL_STA_PRIM_AND_DUAL_FEAS     = 4,
    MSK_SOL_STA_PRIM_INFEAS_CER        = 5,
    MSK_SOL_STA_DUAL_INFEAS_CER        = 6,
    MSK_SOL_STA_NEAR_OPTIMAL           = 8,
    MSK_SOL_STA_NEAR_PRIM_FEAS         = 9,
    MSK_SOL_STA_NEAR_DUAL_FEAS         = 10,
    MSK_SOL_STA_NEAR_PRIM_AND_DUAL_FEAS = 11,
    MSK_SOL_STA_NEAR_PRIM_INFEAS_CER   = 12,
    MSK_SOL_STA_NEAR_DUAL_INFEAS_CER   = 13,
    MSK_SOL_STA_INTEGER_OPTIMAL        = 14,
    MSK_SOL_STA_NEAR_INTEGER_OPTIMAL   = 15
  );

(* Objective sense types *)
type
  MSKobjsense =
  (
    MSK_OBJECTIVE_SENSE_UNDEFINED      = 0,
    MSK_OBJECTIVE_SENSE_MINIMIZE       = 1,
    MSK_OBJECTIVE_SENSE_MAXIMIZE       = 2
  );

(* Solution items *)
type
  MSKsolitem =
  (
    MSK_SOL_ITEM_XC                    = 0,
    MSK_SOL_ITEM_XX                    = 1,
    MSK_SOL_ITEM_Y                     = 2,
    MSK_SOL_ITEM_SLC                   = 3,
    MSK_SOL_ITEM_SUC                   = 4,
    MSK_SOL_ITEM_SLX                   = 5,
    MSK_SOL_ITEM_SUX                   = 6,
    MSK_SOL_ITEM_SNX                   = 7
  );

(* Bound keys *)
type
  MSKboundkey =
  (
    MSK_BK_LO                          = 0,
    MSK_BK_UP                          = 1,
    MSK_BK_FX                          = 2,
    MSK_BK_FR                          = 3,
    MSK_BK_RA                          = 4
  );

(* Specifies the branching direction. *)
const
  MSK_BRANCH_DIR_DOWN                  = 2;
  MSK_BRANCH_DIR_UP                    = 1;
  MSK_BRANCH_DIR_FREE                  = 0;

(* Network detection method *)
const
  MSK_NETWORK_DETECT_SIMPLE            = 1;
  MSK_NETWORK_DETECT_ADVANCED          = 2;
  MSK_NETWORK_DETECT_FREE              = 0;

(* Hot-start type employed by the simplex optimizer *)
type
  MSKsimhotstart =
  (
    MSK_SIM_HOTSTART_NONE              = 0,
    MSK_SIM_HOTSTART_FREE              = 1,
    MSK_SIM_HOTSTART_STATUS_KEYS       = 2
  );

(* Progress call-back codes *)
type
  MSKcallbackcode =
  (
    MSK_CALLBACK_BEGIN_BI              = 0,
    MSK_CALLBACK_BEGIN_CONCURRENT      = 1,
    MSK_CALLBACK_BEGIN_CONIC           = 2,
    MSK_CALLBACK_BEGIN_DUAL_BI         = 3,
    MSK_CALLBACK_BEGIN_DUAL_SENSITIVITY = 4,
    MSK_CALLBACK_BEGIN_DUAL_SETUP_BI   = 5,
    MSK_CALLBACK_BEGIN_DUAL_SIMPLEX    = 6,
    MSK_CALLBACK_BEGIN_INFEAS_ANA      = 7,
    MSK_CALLBACK_BEGIN_INTPNT          = 8,
    MSK_CALLBACK_BEGIN_LICENSE_WAIT    = 9,
    MSK_CALLBACK_BEGIN_MIO             = 10,
    MSK_CALLBACK_BEGIN_NETWORK_DUAL_SIMPLEX = 11,
    MSK_CALLBACK_BEGIN_NETWORK_PRIMAL_SIMPLEX = 12,
    MSK_CALLBACK_BEGIN_NETWORK_SIMPLEX = 13,
    MSK_CALLBACK_BEGIN_NONCONVEX       = 14,
    MSK_CALLBACK_BEGIN_PRESOLVE        = 15,
    MSK_CALLBACK_BEGIN_PRIMAL_BI       = 16,
    MSK_CALLBACK_BEGIN_PRIMAL_SENSITIVITY = 17,
    MSK_CALLBACK_BEGIN_PRIMAL_SETUP_BI = 18,
    MSK_CALLBACK_BEGIN_PRIMAL_SIMPLEX  = 19,
    MSK_CALLBACK_BEGIN_SIMPLEX         = 20,
    MSK_CALLBACK_BEGIN_SIMPLEX_BI      = 21,
    MSK_CALLBACK_BEGIN_SIMPLEX_NETWORK_DETECT = 22,
    MSK_CALLBACK_CONIC                 = 23,
    MSK_CALLBACK_DUAL_SIMPLEX          = 24,
    MSK_CALLBACK_END_BI                = 25,
    MSK_CALLBACK_END_CONCURRENT        = 26,
    MSK_CALLBACK_END_CONIC             = 27,
    MSK_CALLBACK_END_DUAL_BI           = 28,
    MSK_CALLBACK_END_DUAL_SENSITIVITY  = 29,
    MSK_CALLBACK_END_DUAL_SETUP_BI     = 30,
    MSK_CALLBACK_END_DUAL_SIMPLEX      = 31,
    MSK_CALLBACK_END_INFEAS_ANA        = 32,
    MSK_CALLBACK_END_INTPNT            = 33,
    MSK_CALLBACK_END_LICENSE_WAIT      = 34,
    MSK_CALLBACK_END_MIO               = 35,
    MSK_CALLBACK_END_NETWORK_DUAL_SIMPLEX = 36,
    MSK_CALLBACK_END_NETWORK_PRIMAL_SIMPLEX = 37,
    MSK_CALLBACK_END_NETWORK_SIMPLEX   = 38,
    MSK_CALLBACK_END_NONCONVEX         = 39,
    MSK_CALLBACK_END_PRESOLVE          = 40,
    MSK_CALLBACK_END_PRIMAL_BI         = 41,
    MSK_CALLBACK_END_PRIMAL_SENSITIVITY = 42,
    MSK_CALLBACK_END_PRIMAL_SETUP_BI   = 43,
    MSK_CALLBACK_END_PRIMAL_SIMPLEX    = 44,
    MSK_CALLBACK_END_SIMPLEX           = 45,
    MSK_CALLBACK_END_SIMPLEX_BI        = 46,
    MSK_CALLBACK_END_SIMPLEX_NETWORK_DETECT = 47,
    MSK_CALLBACK_IGNORE_VALUE          = 48,
    MSK_CALLBACK_IM_BI                 = 49,
    MSK_CALLBACK_IM_CONIC              = 50,
    MSK_CALLBACK_IM_DUAL_BI            = 51,
    MSK_CALLBACK_IM_DUAL_SENSIVITY     = 52,
    MSK_CALLBACK_IM_DUAL_SIMPLEX       = 53,
    MSK_CALLBACK_IM_INTPNT             = 54,
    MSK_CALLBACK_IM_LICENSE_WAIT       = 55,
    MSK_CALLBACK_IM_MIO                = 56,
    MSK_CALLBACK_IM_MIO_DUAL_SIMPLEX   = 57,
    MSK_CALLBACK_IM_MIO_INTPNT         = 58,
    MSK_CALLBACK_IM_MIO_PRESOLVE       = 59,
    MSK_CALLBACK_IM_MIO_PRIMAL_SIMPLEX = 60,
    MSK_CALLBACK_IM_NETWORK_DUAL_SIMPLEX = 61,
    MSK_CALLBACK_IM_NETWORK_PRIMAL_SIMPLEX = 62,
    MSK_CALLBACK_IM_NONCONVEX          = 63,
    MSK_CALLBACK_IM_PRESOLVE           = 64,
    MSK_CALLBACK_IM_PRIMAL_BI          = 65,
    MSK_CALLBACK_IM_PRIMAL_SENSIVITY   = 66,
    MSK_CALLBACK_IM_PRIMAL_SIMPLEX     = 67,
    MSK_CALLBACK_IM_SIMPLEX_BI         = 68,
    MSK_CALLBACK_INTPNT                = 69,
    MSK_CALLBACK_NEW_INT_MIO           = 70,
    MSK_CALLBACK_NONCOVEX              = 71,
    MSK_CALLBACK_PRIMAL_SIMPLEX        = 72,
    MSK_CALLBACK_QCONE                 = 73,
    MSK_CALLBACK_UPDATE_DUAL_BI        = 74,
    MSK_CALLBACK_UPDATE_DUAL_SIMPLEX   = 75,
    MSK_CALLBACK_UPDATE_NETWORK_DUAL_SIMPLEX = 76,
    MSK_CALLBACK_UPDATE_NETWORK_PRIMAL_SIMPLEX = 77,
    MSK_CALLBACK_UPDATE_NONCONVEX      = 78,
    MSK_CALLBACK_UPDATE_PRESOLVE       = 79,
    MSK_CALLBACK_UPDATE_PRIMAL_BI      = 80,
    MSK_CALLBACK_UPDATE_PRIMAL_SIMPLEX = 81,
    MSK_CALLBACK_UPDATE_SIMPLEX_BI     = 82
  );

(* Problem data items *)
type
  MSKproblemitem =
  (
    MSK_PI_VAR                         = 0,
    MSK_PI_CON                         = 1,
    MSK_PI_CONE                        = 2
  );

(* Stream types *)
type
  MSKstreamtype =
  (
    MSK_STREAM_LOG                     = 0,
    MSK_STREAM_MSG                     = 1,
    MSK_STREAM_ERR                     = 2,
    MSK_STREAM_WRN                     = 3
  );

(* MPS file format type *)
const
  MSK_MPS_FORMAT_STRICT                = 0;
  MSK_MPS_FORMAT_RELAXED               = 1;
  MSK_MPS_FORMAT_FREE                  = 2;

(* Bound keys *)
type
  MSKmark =
  (
    MSK_MARK_LO                        = 0,
    MSK_MARK_UP                        = 1
  );

(* Cone types *)
type
  MSKconetype =
  (
    MSK_CT_QUAD                        = 0,
    MSK_CT_RQUAD                       = 1
  );

(* Feasibility repair types *)
const
  MSK_FEASREPAIR_OPTIMIZE_NONE         = 0;
  MSK_FEASREPAIR_OPTIMIZE_COMBINED     = 2;
  MSK_FEASREPAIR_OPTIMIZE_PENALTY      = 1;

(* Input/output modes *)
const
  MSK_IOMODE_READ                      = 0;
  MSK_IOMODE_WRITE                     = 1;
  MSK_IOMODE_READWRITE                 = 2;

(* String parameter types *)
type
  MSKsparam =
  (
    MSK_SPAR_BAS_SOL_FILE_NAME         = 0,
    MSK_SPAR_DATA_FILE_NAME            = 1,
    MSK_SPAR_DEBUG_FILE_NAME           = 2,
    MSK_SPAR_FEASREPAIR_NAME_PREFIX    = 3,
    MSK_SPAR_FEASREPAIR_NAME_SEPARATOR = 4,
    MSK_SPAR_FEASREPAIR_NAME_WSUMVIOL  = 5,
    MSK_SPAR_INT_SOL_FILE_NAME         = 6,
    MSK_SPAR_ITR_SOL_FILE_NAME         = 7,
    MSK_SPAR_PARAM_COMMENT_SIGN        = 8,
    MSK_SPAR_PARAM_READ_FILE_NAME      = 9,
    MSK_SPAR_PARAM_WRITE_FILE_NAME     = 10,
    MSK_SPAR_READ_MPS_BOU_NAME         = 11,
    MSK_SPAR_READ_MPS_OBJ_NAME         = 12,
    MSK_SPAR_READ_MPS_RAN_NAME         = 13,
    MSK_SPAR_READ_MPS_RHS_NAME         = 14,
    MSK_SPAR_SENSITIVITY_FILE_NAME     = 15,
    MSK_SPAR_SENSITIVITY_RES_FILE_NAME = 16,
    MSK_SPAR_SOL_FILTER_XC_LOW         = 17,
    MSK_SPAR_SOL_FILTER_XC_UPR         = 18,
    MSK_SPAR_SOL_FILTER_XX_LOW         = 19,
    MSK_SPAR_SOL_FILTER_XX_UPR         = 20,
    MSK_SPAR_STAT_FILE_NAME            = 21,
    MSK_SPAR_STAT_KEY                  = 22,
    MSK_SPAR_STAT_NAME                 = 23,
    MSK_SPAR_WRITE_LP_GEN_VAR_NAME     = 24
  );

(* Simplex selection strategy *)
const
  MSK_SIM_SELECTION_FULL               = 1;
  MSK_SIM_SELECTION_PARTIAL            = 5;
  MSK_SIM_SELECTION_FREE               = 0;
  MSK_SIM_SELECTION_ASE                = 2;
  MSK_SIM_SELECTION_DEVEX              = 3;
  MSK_SIM_SELECTION_SE                 = 4;

(* Message keys *)
type
  MSKmsgkey =
  (
    MSK_MSG_READING_FILE               = 1000,
    MSK_MSG_WRITING_FILE               = 1001,
    MSK_MSG_MPS_SELECTED               = 1100
  );

(* Integer restrictions *)
const
  MSK_MIO_MODE_IGNORED                 = 0;
  MSK_MIO_MODE_LAZY                    = 2;
  MSK_MIO_MODE_SATISFIED               = 1;

(* Double information items *)
type
  MSKdinfitem =
  (
    MSK_DINF_BI_CLEAN_CPUTIME          = 0,
    MSK_DINF_BI_CPUTIME                = 1,
    MSK_DINF_BI_DUAL_CPUTIME           = 2,
    MSK_DINF_BI_PRIMAL_CPUTIME         = 3,
    MSK_DINF_CONCURRENT_CPUTIME        = 4,
    MSK_DINF_CONCURRENT_REALTIME       = 5,
    MSK_DINF_INTPNT_CPUTIME            = 6,
    MSK_DINF_INTPNT_DUAL_FEAS          = 7,
    MSK_DINF_INTPNT_DUAL_OBJ           = 8,
    MSK_DINF_INTPNT_FACTOR_NUM_FLOPS   = 9,
    MSK_DINF_INTPNT_KAP_DIV_TAU        = 10,
    MSK_DINF_INTPNT_ORDER_CPUTIME      = 11,
    MSK_DINF_INTPNT_PRIMAL_FEAS        = 12,
    MSK_DINF_INTPNT_PRIMAL_OBJ         = 13,
    MSK_DINF_INTPNT_REALTIME           = 14,
    MSK_DINF_MIO_CONSTRUCT_SOLUTION_OBJ = 15,
    MSK_DINF_MIO_CPUTIME               = 16,
    MSK_DINF_MIO_OBJ_ABS_GAP           = 17,
    MSK_DINF_MIO_OBJ_BOUND             = 18,
    MSK_DINF_MIO_OBJ_INT               = 19,
    MSK_DINF_MIO_OBJ_REL_GAP           = 20,
    MSK_DINF_MIO_USER_OBJ_CUT          = 21,
    MSK_DINF_OPTIMIZER_CPUTIME         = 22,
    MSK_DINF_OPTIMIZER_REALTIME        = 23,
    MSK_DINF_PRESOLVE_CPUTIME          = 24,
    MSK_DINF_PRESOLVE_ELI_CPUTIME      = 25,
    MSK_DINF_PRESOLVE_LINDEP_CPUTIME   = 26,
    MSK_DINF_RD_CPUTIME                = 27,
    MSK_DINF_SIM_CPUTIME               = 28,
    MSK_DINF_SIM_FEAS                  = 29,
    MSK_DINF_SIM_OBJ                   = 30,
    MSK_DINF_SOL_BAS_DUAL_OBJ          = 31,
    MSK_DINF_SOL_BAS_MAX_DBI           = 32,
    MSK_DINF_SOL_BAS_MAX_DEQI          = 33,
    MSK_DINF_SOL_BAS_MAX_PBI           = 34,
    MSK_DINF_SOL_BAS_MAX_PEQI          = 35,
    MSK_DINF_SOL_BAS_MAX_PINTI         = 36,
    MSK_DINF_SOL_BAS_PRIMAL_OBJ        = 37,
    MSK_DINF_SOL_INT_MAX_PBI           = 38,
    MSK_DINF_SOL_INT_MAX_PEQI          = 39,
    MSK_DINF_SOL_INT_MAX_PINTI         = 40,
    MSK_DINF_SOL_INT_PRIMAL_OBJ        = 41,
    MSK_DINF_SOL_ITR_DUAL_OBJ          = 42,
    MSK_DINF_SOL_ITR_MAX_DBI           = 43,
    MSK_DINF_SOL_ITR_MAX_DCNI          = 44,
    MSK_DINF_SOL_ITR_MAX_DEQI          = 45,
    MSK_DINF_SOL_ITR_MAX_PBI           = 46,
    MSK_DINF_SOL_ITR_MAX_PCNI          = 47,
    MSK_DINF_SOL_ITR_MAX_PEQI          = 48,
    MSK_DINF_SOL_ITR_MAX_PINTI         = 49,
    MSK_DINF_SOL_ITR_PRIMAL_OBJ        = 50
  );

(* Parameter type *)
type
  MSKparametertype =
  (
    MSK_PAR_INVALID_TYPE               = 0,
    MSK_PAR_DOU_TYPE                   = 1,
    MSK_PAR_INT_TYPE                   = 2,
    MSK_PAR_STR_TYPE                   = 3
  );

(* Response code type *)
type
  MSKrescodetype =
  (
    MSK_RESPONSE_OK                    = 0,
    MSK_RESPONSE_WRN                   = 1,
    MSK_RESPONSE_TRM                   = 2,
    MSK_RESPONSE_ERR                   = 3,
    MSK_RESPONSE_UNK                   = 4
  );

(* Problem status keys *)
type
  MSKprosta =
  (
    MSK_PRO_STA_UNKNOWN                = 0,
    MSK_PRO_STA_PRIM_AND_DUAL_FEAS     = 1,
    MSK_PRO_STA_PRIM_FEAS              = 2,
    MSK_PRO_STA_DUAL_FEAS              = 3,
    MSK_PRO_STA_PRIM_INFEAS            = 4,
    MSK_PRO_STA_DUAL_INFEAS            = 5,
    MSK_PRO_STA_PRIM_AND_DUAL_INFEAS   = 6,
    MSK_PRO_STA_ILL_POSED              = 7,
    MSK_PRO_STA_NEAR_PRIM_AND_DUAL_FEAS = 8,
    MSK_PRO_STA_NEAR_PRIM_FEAS         = 9,
    MSK_PRO_STA_NEAR_DUAL_FEAS         = 10,
    MSK_PRO_STA_PRIM_INFEAS_OR_UNBOUNDED = 11
  );

(* Scaling type *)
const
  MSK_SCALING_NONE                     = 1;
  MSK_SCALING_MODERATE                 = 2;
  MSK_SCALING_AGGRESSIVE               = 3;
  MSK_SCALING_FREE                     = 0;

(* Response codes *)
type
  MSKrescode =
  (
    MSK_RES_OK                         = 0,
    MSK_RES_WRN_OPEN_PARAM_FILE        = 50,
    MSK_RES_WRN_LARGE_BOUND            = 51,
    MSK_RES_WRN_LARGE_LO_BOUND         = 52,
    MSK_RES_WRN_LARGE_UP_BOUND         = 53,
    MSK_RES_WRN_LARGE_CJ               = 57,
    MSK_RES_WRN_LARGE_AIJ              = 62,
    MSK_RES_WRN_ZERO_AIJ               = 63,
    MSK_RES_WRN_NAME_MAX_LEN           = 65,
    MSK_RES_WRN_SPAR_MAX_LEN           = 66,
    MSK_RES_WRN_MPS_SPLIT_RHS_VECTOR   = 70,
    MSK_RES_WRN_MPS_SPLIT_RAN_VECTOR   = 71,
    MSK_RES_WRN_MPS_SPLIT_BOU_VECTOR   = 72,
    MSK_RES_WRN_LP_OLD_QUAD_FORMAT     = 80,
    MSK_RES_WRN_LP_DROP_VARIABLE       = 85,
    MSK_RES_WRN_NZ_IN_UPR_TRI          = 200,
    MSK_RES_WRN_DROPPED_NZ_QOBJ        = 201,
    MSK_RES_WRN_IGNORE_INTEGER         = 250,
    MSK_RES_WRN_NO_GLOBAL_OPTIMIZER    = 251,
    MSK_RES_WRN_MIO_INFEASIBLE_FINAL   = 270,
    MSK_RES_WRN_FIXED_BOUND_VALUES     = 280,
    MSK_RES_WRN_SOL_FILTER             = 300,
    MSK_RES_WRN_UNDEF_SOL_FILE_NAME    = 350,
    MSK_RES_WRN_TOO_FEW_BASIS_VARS     = 400,
    MSK_RES_WRN_TOO_MANY_BASIS_VARS    = 405,
    MSK_RES_WRN_LICENSE_EXPIRE         = 500,
    MSK_RES_WRN_LICENSE_SERVER         = 501,
    MSK_RES_WRN_EMPTY_NAME             = 502,
    MSK_RES_WRN_USING_GENERIC_NAMES    = 503,
    MSK_RES_WRN_LICENSE_FEATURE_EXPIRE = 505,
    MSK_RES_WRN_ZEROS_IN_SPARSE_DATA   = 700,
    MSK_RES_WRN_NONCOMPLETE_LINEAR_DEPENDENCY_CHECK = 800,
    MSK_RES_WRN_ELIMINATOR_SPACE       = 801,
    MSK_RES_WRN_PRESOLVE_OUTOFSPACE    = 802,
    MSK_RES_WRN_PRESOLVE_BAD_PRECISION = 803,
    MSK_RES_WRN_WRITE_DISCARDED_CFIX   = 804,
    MSK_RES_ERR_LICENSE                = 1000,
    MSK_RES_ERR_LICENSE_EXPIRED        = 1001,
    MSK_RES_ERR_LICENSE_VERSION        = 1002,
    MSK_RES_ERR_SIZE_LICENSE           = 1005,
    MSK_RES_ERR_PROB_LICENSE           = 1006,
    MSK_RES_ERR_FILE_LICENSE           = 1007,
    MSK_RES_ERR_MISSING_LICENSE_FILE   = 1008,
    MSK_RES_ERR_SIZE_LICENSE_CON       = 1010,
    MSK_RES_ERR_SIZE_LICENSE_VAR       = 1011,
    MSK_RES_ERR_SIZE_LICENSE_INTVAR    = 1012,
    MSK_RES_ERR_OPTIMIZER_LICENSE      = 1013,
    MSK_RES_ERR_FLEXLM                 = 1014,
    MSK_RES_ERR_LICENSE_SERVER         = 1015,
    MSK_RES_ERR_LICENSE_MAX            = 1016,
    MSK_RES_ERR_LICENSE_MOSEKLM_DAEMON = 1017,
    MSK_RES_ERR_LICENSE_FEATURE        = 1018,
    MSK_RES_ERR_PLATFORM_NOT_LICENSED  = 1019,
    MSK_RES_ERR_LICENSE_CANNOT_ALLOCATE = 1020,
    MSK_RES_ERR_LICENSE_CANNOT_CONNECT = 1021,
    MSK_RES_ERR_LICENSE_INVALID_HOSTID = 1025,
    MSK_RES_ERR_LICENSE_SERVER_VERSION = 1026,
    MSK_RES_ERR_OPEN_DL                = 1030,
    MSK_RES_ERR_OLDER_DLL              = 1035,
    MSK_RES_ERR_NEWER_DLL              = 1036,
    MSK_RES_ERR_LINK_FILE_DLL          = 1040,
    MSK_RES_ERR_THREAD_MUTEX_INIT      = 1045,
    MSK_RES_ERR_THREAD_MUTEX_LOCK      = 1046,
    MSK_RES_ERR_THREAD_MUTEX_UNLOCK    = 1047,
    MSK_RES_ERR_THREAD_CREATE          = 1048,
    MSK_RES_ERR_THREAD_COND_INIT       = 1049,
    MSK_RES_ERR_UNKNOWN                = 1050,
    MSK_RES_ERR_SPACE                  = 1051,
    MSK_RES_ERR_FILE_OPEN              = 1052,
    MSK_RES_ERR_FILE_READ              = 1053,
    MSK_RES_ERR_FILE_WRITE             = 1054,
    MSK_RES_ERR_DATA_FILE_EXT          = 1055,
    MSK_RES_ERR_INVALID_FILE_NAME      = 1056,
    MSK_RES_ERR_INVALID_SOL_FILE_NAME  = 1057,
    MSK_RES_ERR_INVALID_MBT_FILE       = 1058,
    MSK_RES_ERR_END_OF_FILE            = 1059,
    MSK_RES_ERR_NULL_ENV               = 1060,
    MSK_RES_ERR_NULL_TASK              = 1061,
    MSK_RES_ERR_INVALID_STREAM         = 1062,
    MSK_RES_ERR_NO_INIT_ENV            = 1063,
    MSK_RES_ERR_INVALID_TASK           = 1064,
    MSK_RES_ERR_NULL_POINTER           = 1065,
    MSK_RES_ERR_NULL_NAME              = 1070,
    MSK_RES_ERR_DUP_NAME               = 1071,
    MSK_RES_ERR_INVALID_OBJ_NAME       = 1075,
    MSK_RES_ERR_SPACE_LEAKING          = 1080,
    MSK_RES_ERR_SPACE_NO_INFO          = 1081,
    MSK_RES_ERR_READ_FORMAT            = 1090,
    MSK_RES_ERR_MPS_FILE               = 1100,
    MSK_RES_ERR_MPS_INV_FIELD          = 1101,
    MSK_RES_ERR_MPS_INV_MARKER         = 1102,
    MSK_RES_ERR_MPS_NULL_CON_NAME      = 1103,
    MSK_RES_ERR_MPS_NULL_VAR_NAME      = 1104,
    MSK_RES_ERR_MPS_UNDEF_CON_NAME     = 1105,
    MSK_RES_ERR_MPS_UNDEF_VAR_NAME     = 1106,
    MSK_RES_ERR_MPS_INV_CON_KEY        = 1107,
    MSK_RES_ERR_MPS_INV_BOUND_KEY      = 1108,
    MSK_RES_ERR_MPS_INV_SEC_NAME       = 1109,
    MSK_RES_ERR_MPS_NO_OBJECTIVE       = 1110,
    MSK_RES_ERR_MPS_SPLITTED_VAR       = 1111,
    MSK_RES_ERR_MPS_MUL_CON_NAME       = 1112,
    MSK_RES_ERR_MPS_MUL_QSEC           = 1113,
    MSK_RES_ERR_MPS_MUL_QOBJ           = 1114,
    MSK_RES_ERR_MPS_INV_SEC_ORDER      = 1115,
    MSK_RES_ERR_MPS_MUL_CSEC           = 1116,
    MSK_RES_ERR_MPS_CONE_TYPE          = 1117,
    MSK_RES_ERR_MPS_CONE_OVERLAP       = 1118,
    MSK_RES_ERR_MPS_CONE_REPEAT        = 1119,
    MSK_RES_ERR_MPS_INVALID_OBJSENSE   = 1122,
    MSK_RES_ERR_MPS_TAB_IN_FIELD2      = 1125,
    MSK_RES_ERR_MPS_TAB_IN_FIELD3      = 1126,
    MSK_RES_ERR_MPS_TAB_IN_FIELD5      = 1127,
    MSK_RES_ERR_MPS_INVALID_OBJ_NAME   = 1128,
    MSK_RES_ERR_ORD_INVALID_BRANCH_DIR = 1130,
    MSK_RES_ERR_ORD_INVALID            = 1131,
    MSK_RES_ERR_LP_INCOMPATIBLE        = 1150,
    MSK_RES_ERR_LP_EMPTY               = 1151,
    MSK_RES_ERR_LP_DUP_SLACK_NAME      = 1152,
    MSK_RES_ERR_WRITE_MPS_INVALID_NAME = 1153,
    MSK_RES_ERR_LP_INVALID_VAR_NAME    = 1154,
    MSK_RES_ERR_LP_FREE_CONSTRAINT     = 1155,
    MSK_RES_ERR_WRITE_OPF_INVALID_VAR_NAME = 1156,
    MSK_RES_ERR_LP_FILE_FORMAT         = 1157,
    MSK_RES_ERR_WRITE_LP_FORMAT        = 1158,
    MSK_RES_ERR_LP_FORMAT              = 1160,
    MSK_RES_ERR_WRITE_LP_NON_UNIQUE_NAME = 1161,
    MSK_RES_ERR_READ_LP_NONEXISTING_NAME = 1162,
    MSK_RES_ERR_LP_WRITE_CONIC_PROBLEM = 1163,
    MSK_RES_ERR_LP_WRITE_GECO_PROBLEM  = 1164,
    MSK_RES_ERR_NAME_MAX_LEN           = 1165,
    MSK_RES_ERR_OPF_FORMAT             = 1168,
    MSK_RES_ERR_INVALID_NAME_IN_SOL_FILE = 1170,
    MSK_RES_ERR_ARGUMENT_LENNEQ        = 1197,
    MSK_RES_ERR_ARGUMENT_TYPE          = 1198,
    MSK_RES_ERR_NR_ARGUMENTS           = 1199,
    MSK_RES_ERR_IN_ARGUMENT            = 1200,
    MSK_RES_ERR_ARGUMENT_DIMENSION     = 1201,
    MSK_RES_ERR_INDEX_IS_TOO_SMALL     = 1203,
    MSK_RES_ERR_INDEX_IS_TOO_LARGE     = 1204,
    MSK_RES_ERR_PARAM_NAME             = 1205,
    MSK_RES_ERR_PARAM_NAME_DOU         = 1206,
    MSK_RES_ERR_PARAM_NAME_INT         = 1207,
    MSK_RES_ERR_PARAM_NAME_STR         = 1208,
    MSK_RES_ERR_PARAM_INDEX            = 1210,
    MSK_RES_ERR_PARAM_IS_TOO_LARGE     = 1215,
    MSK_RES_ERR_PARAM_IS_TOO_SMALL     = 1216,
    MSK_RES_ERR_PARAM_VALUE_STR        = 1217,
    MSK_RES_ERR_PARAM_TYPE             = 1218,
    MSK_RES_ERR_INF_DOU_INDEX          = 1219,
    MSK_RES_ERR_INF_INT_INDEX          = 1220,
    MSK_RES_ERR_INDEX_ARR_IS_TOO_SMALL = 1221,
    MSK_RES_ERR_INDEX_ARR_IS_TOO_LARGE = 1222,
    MSK_RES_ERR_INF_DOU_NAME           = 1230,
    MSK_RES_ERR_INF_INT_NAME           = 1231,
    MSK_RES_ERR_INF_TYPE               = 1232,
    MSK_RES_ERR_INDEX                  = 1235,
    MSK_RES_ERR_WHICHSOL               = 1236,
    MSK_RES_ERR_SOLITEM                = 1237,
    MSK_RES_ERR_WHICHITEM_NOT_ALLOWED  = 1238,
    MSK_RES_ERR_MAXNUMCON              = 1240,
    MSK_RES_ERR_MAXNUMVAR              = 1241,
    MSK_RES_ERR_MAXNUMANZ              = 1242,
    MSK_RES_ERR_MAXNUMQNZ              = 1243,
    MSK_RES_ERR_NUMCONLIM              = 1250,
    MSK_RES_ERR_NUMVARLIM              = 1251,
    MSK_RES_ERR_TOO_SMALL_MAXNUMANZ    = 1252,
    MSK_RES_ERR_INV_APTRE              = 1253,
    MSK_RES_ERR_MUL_A_ELEMENT          = 1254,
    MSK_RES_ERR_INV_BK                 = 1255,
    MSK_RES_ERR_INV_BKC                = 1256,
    MSK_RES_ERR_INV_BKX                = 1257,
    MSK_RES_ERR_INV_VAR_TYPE           = 1258,
    MSK_RES_ERR_SOLVER_PROBTYPE        = 1259,
    MSK_RES_ERR_OBJECTIVE_RANGE        = 1260,
    MSK_RES_ERR_FIRST                  = 1261,
    MSK_RES_ERR_LAST                   = 1262,
    MSK_RES_ERR_NEGATIVE_SURPLUS       = 1263,
    MSK_RES_ERR_NEGATIVE_APPEND        = 1264,
    MSK_RES_ERR_UNDEF_SOLUTION         = 1265,
    MSK_RES_ERR_BASIS                  = 1266,
    MSK_RES_ERR_INV_SKC                = 1267,
    MSK_RES_ERR_INV_SKX                = 1268,
    MSK_RES_ERR_INV_SK_STR             = 1269,
    MSK_RES_ERR_INV_SK                 = 1270,
    MSK_RES_ERR_INV_CONE_TYPE_STR      = 1271,
    MSK_RES_ERR_INV_CONE_TYPE          = 1272,
    MSK_RES_ERR_INV_SKN                = 1274,
    MSK_RES_ERR_INV_NAME_ITEM          = 1280,
    MSK_RES_ERR_PRO_ITEM               = 1281,
    MSK_RES_ERR_INVALID_FORMAT_TYPE    = 1283,
    MSK_RES_ERR_FIRSTI                 = 1285,
    MSK_RES_ERR_LASTI                  = 1286,
    MSK_RES_ERR_FIRSTJ                 = 1287,
    MSK_RES_ERR_LASTJ                  = 1288,
    MSK_RES_ERR_NONLINEAR_EQUALITY     = 1290,
    MSK_RES_ERR_NONCONVEX              = 1291,
    MSK_RES_ERR_NONLINEAR_RANGED       = 1292,
    MSK_RES_ERR_CON_Q_NOT_PSD          = 1293,
    MSK_RES_ERR_CON_Q_NOT_NSD          = 1294,
    MSK_RES_ERR_OBJ_Q_NOT_PSD          = 1295,
    MSK_RES_ERR_OBJ_Q_NOT_NSD          = 1296,
    MSK_RES_ERR_ARGUMENT_PERM_ARRAY    = 1299,
    MSK_RES_ERR_CONE_INDEX             = 1300,
    MSK_RES_ERR_CONE_SIZE              = 1301,
    MSK_RES_ERR_CONE_OVERLAP           = 1302,
    MSK_RES_ERR_CONE_REP_VAR           = 1303,
    MSK_RES_ERR_MAXNUMCONE             = 1304,
    MSK_RES_ERR_CONE_TYPE              = 1305,
    MSK_RES_ERR_CONE_TYPE_STR          = 1306,
    MSK_RES_ERR_REMOVE_CONE_VARIABLE   = 1310,
    MSK_RES_ERR_SOL_FILE_NUMBER        = 1350,
    MSK_RES_ERR_HUGE_C                 = 1375,
    MSK_RES_ERR_INFINITE_BOUND         = 1400,
    MSK_RES_ERR_INV_QOBJ_SUBI          = 1401,
    MSK_RES_ERR_INV_QOBJ_SUBJ          = 1402,
    MSK_RES_ERR_INV_QOBJ_VAL           = 1403,
    MSK_RES_ERR_INV_QCON_SUBK          = 1404,
    MSK_RES_ERR_INV_QCON_SUBI          = 1405,
    MSK_RES_ERR_INV_QCON_SUBJ          = 1406,
    MSK_RES_ERR_INV_QCON_VAL           = 1407,
    MSK_RES_ERR_QCON_SUBI_TOO_SMALL    = 1408,
    MSK_RES_ERR_QCON_SUBI_TOO_LARGE    = 1409,
    MSK_RES_ERR_QOBJ_UPPER_TRIANGLE    = 1415,
    MSK_RES_ERR_QCON_UPPER_TRIANGLE    = 1417,
    MSK_RES_ERR_USER_FUNC_RET          = 1430,
    MSK_RES_ERR_USER_FUNC_RET_DATA     = 1431,
    MSK_RES_ERR_USER_NLO_FUNC          = 1432,
    MSK_RES_ERR_USER_NLO_EVAL          = 1433,
    MSK_RES_ERR_USER_NLO_EVAL_HESSUBI  = 1440,
    MSK_RES_ERR_USER_NLO_EVAL_HESSUBJ  = 1441,
    MSK_RES_ERR_INVALID_OBJECTIVE_SENSE = 1445,
    MSK_RES_ERR_UNDEFINED_OBJECTIVE_SENSE = 1446,
    MSK_RES_ERR_Y_IS_UNDEFINED         = 1449,
    MSK_RES_ERR_NAN_IN_DOUBLE_DATA     = 1450,
    MSK_RES_ERR_NAN_IN_BLC             = 1461,
    MSK_RES_ERR_NAN_IN_BUC             = 1462,
    MSK_RES_ERR_NAN_IN_C               = 1470,
    MSK_RES_ERR_NAN_IN_BLX             = 1471,
    MSK_RES_ERR_NAN_IN_BUX             = 1472,
    MSK_RES_ERR_INV_PROBLEM            = 1500,
    MSK_RES_ERR_MIXED_PROBLEM          = 1501,
    MSK_RES_ERR_INV_OPTIMIZER          = 1550,
    MSK_RES_ERR_MIO_NO_OPTIMIZER       = 1551,
    MSK_RES_ERR_NO_OPTIMIZER_VAR_TYPE  = 1552,
    MSK_RES_ERR_MIO_NOT_LOADED         = 1553,
    MSK_RES_ERR_POSTSOLVE              = 1580,
    MSK_RES_ERR_NO_BASIS_SOL           = 1600,
    MSK_RES_ERR_BASIS_FACTOR           = 1610,
    MSK_RES_ERR_BASIS_SINGULAR         = 1615,
    MSK_RES_ERR_FACTOR                 = 1650,
    MSK_RES_ERR_FEASREPAIR_CANNOT_RELAX = 1700,
    MSK_RES_ERR_FEASREPAIR_SOLVING_RELAXED = 1701,
    MSK_RES_ERR_FEASREPAIR_INCONSISTENT_BOUND = 1702,
    MSK_RES_ERR_INVALID_COMPRESSION    = 1800,
    MSK_RES_ERR_INVALID_IOMODE         = 1801,
    MSK_RES_ERR_NO_PRIMAL_INFEAS_CER   = 2000,
    MSK_RES_ERR_NO_DUAL_INFEAS_CER     = 2001,
    MSK_RES_ERR_NO_SOLUTION_IN_CALLBACK = 2500,
    MSK_RES_ERR_INV_MARKI              = 2501,
    MSK_RES_ERR_INV_MARKJ              = 2502,
    MSK_RES_ERR_INV_NUMI               = 2503,
    MSK_RES_ERR_INV_NUMJ               = 2504,
    MSK_RES_ERR_CANNOT_CLONE_NL        = 2505,
    MSK_RES_ERR_CANNOT_HANDLE_NL       = 2506,
    MSK_RES_ERR_INVALID_ACCMODE        = 2520,
    MSK_RES_ERR_MBT_INCOMPATIBLE       = 2550,
    MSK_RES_ERR_LU_MAX_NUM_TRIES       = 2800,
    MSK_RES_ERR_INVALID_UTF8           = 2900,
    MSK_RES_ERR_INVALID_WCHAR          = 2901,
    MSK_RES_ERR_NO_DUAL_FOR_ITG_SOL    = 2950,
    MSK_RES_ERR_INTERNAL               = 3000,
    MSK_RES_ERR_API_ARRAY_TOO_SMALL    = 3001,
    MSK_RES_ERR_API_CB_CONNECT         = 3002,
    MSK_RES_ERR_API_NL_DATA            = 3003,
    MSK_RES_ERR_API_CALLBACK           = 3004,
    MSK_RES_ERR_API_FATAL_ERROR        = 3005,
    MSK_RES_ERR_SEN_FORMAT             = 3050,
    MSK_RES_ERR_SEN_UNDEF_NAME         = 3051,
    MSK_RES_ERR_SEN_INDEX_RANGE        = 3052,
    MSK_RES_ERR_SEN_BOUND_INVALID_UP   = 3053,
    MSK_RES_ERR_SEN_BOUND_INVALID_LO   = 3054,
    MSK_RES_ERR_SEN_INDEX_INVALID      = 3055,
    MSK_RES_ERR_SEN_INVALID_REGEXP     = 3056,
    MSK_RES_ERR_SEN_SOLUTION_STATUS    = 3057,
    MSK_RES_ERR_SEN_NUMERICAL          = 3058,
    MSK_RES_ERR_CONCURRENT_OPTIMIZER   = 3059,
    MSK_RES_ERR_UNB_STEP_SIZE          = 3100,
    MSK_RES_ERR_IDENTICAL_TASKS        = 3101,
    MSK_RES_ERR_INVALID_BRANCH_DIRECTION = 3200,
    MSK_RES_ERR_INVALID_BRANCH_PRIORITY = 3201,
    MSK_RES_ERR_INTERNAL_TEST_FAILED   = 3500,
    MSK_RES_ERR_XML_INVALID_PROBLEM_TYPE = 3600,
    MSK_RES_ERR_INVALID_AMPL_STUB      = 3700,
    MSK_RES_ERR_API_INTERNAL           = 3999,
    MSK_RES_TRM_MAX_ITERATIONS         = 4000,
    MSK_RES_TRM_MAX_TIME               = 4001,
    MSK_RES_TRM_OBJECTIVE_RANGE        = 4002,
    MSK_RES_TRM_MIO_NEAR_REL_GAP       = 4003,
    MSK_RES_TRM_MIO_NEAR_ABS_GAP       = 4004,
    MSK_RES_TRM_USER_BREAK             = 4005,
    MSK_RES_TRM_STALL                  = 4006,
    MSK_RES_TRM_USER_CALLBACK          = 4007,
    MSK_RES_TRM_MIO_NUM_RELAXS         = 4008,
    MSK_RES_TRM_MIO_NUM_BRANCHES       = 4009,
    MSK_RES_TRM_NUM_MAX_NUM_INT_SOLUTIONS = 4015,
    MSK_RES_TRM_MAX_NUM_SETBACKS       = 4020,
    MSK_RES_TRM_NUMERICAL_PROBLEM      = 4025,
    MSK_RES_TRM_INTERNAL               = 4030,
    MSK_RES_TRM_INTERNAL_STOP          = 4031
  );

(* Double values *)
const
  MSK_INFINITY                         = 1e+30;

(* Mixed integer node selection types *)
const
  MSK_MIO_NODE_SELECTION_PSEUDO        = 5;
  MSK_MIO_NODE_SELECTION_HYBRID        = 4;
  MSK_MIO_NODE_SELECTION_FREE          = 0;
  MSK_MIO_NODE_SELECTION_WORST         = 3;
  MSK_MIO_NODE_SELECTION_BEST          = 2;
  MSK_MIO_NODE_SELECTION_FIRST         = 1;

(* On/off *)
const
  MSK_ON                               = 1;
  MSK_OFF                              = 0;

(* Degeneracy strategies *)
type
  MSKsimdegen =
  (
    MSK_SIM_DEGEN_NONE                 = 0,
    MSK_SIM_DEGEN_FREE                 = 1,
    MSK_SIM_DEGEN_AGGRESSIVE           = 2,
    MSK_SIM_DEGEN_MODERATE             = 3,
    MSK_SIM_DEGEN_MINIMUM              = 4
  );

(* Data format types *)
const
  MSK_DATA_FORMAT_XML                  = 5;
  MSK_DATA_FORMAT_EXTENSION            = 0;
  MSK_DATA_FORMAT_MPS                  = 1;
  MSK_DATA_FORMAT_LP                   = 2;
  MSK_DATA_FORMAT_MBT                  = 3;
  MSK_DATA_FORMAT_OP                   = 4;

(* Ordering strategies *)
const
  MSK_ORDER_METHOD_NONE                = 5;
  MSK_ORDER_METHOD_APPMINLOC2          = 2;
  MSK_ORDER_METHOD_APPMINLOC1          = 1;
  MSK_ORDER_METHOD_GRAPHPAR2           = 4;
  MSK_ORDER_METHOD_FREE                = 0;
  MSK_ORDER_METHOD_GRAPHPAR1           = 3;

(* Problem types *)
type
  MSKproblemtype =
  (
    MSK_PROBTYPE_LO                    = 0,
    MSK_PROBTYPE_QO                    = 1,
    MSK_PROBTYPE_QCQO                  = 2,
    MSK_PROBTYPE_GECO                  = 3,
    MSK_PROBTYPE_CONIC                 = 4,
    MSK_PROBTYPE_MIXED                 = 5
  );

(* Information item types *)
type
  MSKinftype =
  (
    MSK_INF_DOU_TYPE                   = 0,
    MSK_INF_INT_TYPE                   = 1
  );

(* Presolve method. *)
const
  MSK_PRESOLVE_MODE_ON                 = 1;
  MSK_PRESOLVE_MODE_OFF                = 0;
  MSK_PRESOLVE_MODE_FREE               = 2;

(* Double parameters *)
type
  MSKdparam =
  (
    MSK_DPAR_BASIS_REL_TOL_S           = 0,
    MSK_DPAR_BASIS_TOL_S               = 1,
    MSK_DPAR_BASIS_TOL_X               = 2,
    MSK_DPAR_BI_LU_TOL_REL_PIV         = 3,
    MSK_DPAR_CALLBACK_FREQ             = 4,
    MSK_DPAR_DATA_TOL_AIJ              = 5,
    MSK_DPAR_DATA_TOL_AIJ_LARGE        = 6,
    MSK_DPAR_DATA_TOL_BOUND_INF        = 7,
    MSK_DPAR_DATA_TOL_BOUND_WRN        = 8,
    MSK_DPAR_DATA_TOL_C_HUGE           = 9,
    MSK_DPAR_DATA_TOL_CJ_LARGE         = 10,
    MSK_DPAR_DATA_TOL_QIJ              = 11,
    MSK_DPAR_DATA_TOL_X                = 12,
    MSK_DPAR_FEASREPAIR_TOL            = 13,
    MSK_DPAR_INTPNT_CO_TOL_DFEAS       = 14,
    MSK_DPAR_INTPNT_CO_TOL_INFEAS      = 15,
    MSK_DPAR_INTPNT_CO_TOL_MU_RED      = 16,
    MSK_DPAR_INTPNT_CO_TOL_NEAR_REL    = 17,
    MSK_DPAR_INTPNT_CO_TOL_PFEAS       = 18,
    MSK_DPAR_INTPNT_CO_TOL_REL_GAP     = 19,
    MSK_DPAR_INTPNT_NL_MERIT_BAL       = 20,
    MSK_DPAR_INTPNT_NL_TOL_DFEAS       = 21,
    MSK_DPAR_INTPNT_NL_TOL_MU_RED      = 22,
    MSK_DPAR_INTPNT_NL_TOL_NEAR_REL    = 23,
    MSK_DPAR_INTPNT_NL_TOL_PFEAS       = 24,
    MSK_DPAR_INTPNT_NL_TOL_REL_GAP     = 25,
    MSK_DPAR_INTPNT_NL_TOL_REL_STEP    = 26,
    MSK_DPAR_INTPNT_TOL_DFEAS          = 27,
    MSK_DPAR_INTPNT_TOL_DSAFE          = 28,
    MSK_DPAR_INTPNT_TOL_INFEAS         = 29,
    MSK_DPAR_INTPNT_TOL_MU_RED         = 30,
    MSK_DPAR_INTPNT_TOL_PATH           = 31,
    MSK_DPAR_INTPNT_TOL_PFEAS          = 32,
    MSK_DPAR_INTPNT_TOL_PSAFE          = 33,
    MSK_DPAR_INTPNT_TOL_REL_GAP        = 34,
    MSK_DPAR_INTPNT_TOL_REL_STEP       = 35,
    MSK_DPAR_INTPNT_TOL_STEP_SIZE      = 36,
    MSK_DPAR_LOWER_OBJ_CUT             = 37,
    MSK_DPAR_LOWER_OBJ_CUT_FINITE_TRH  = 38,
    MSK_DPAR_MIO_DISABLE_TERM_TIME     = 39,
    MSK_DPAR_MIO_HEURISTIC_TIME        = 40,
    MSK_DPAR_MIO_MAX_TIME              = 41,
    MSK_DPAR_MIO_MAX_TIME_APRX_OPT     = 42,
    MSK_DPAR_MIO_NEAR_TOL_ABS_GAP      = 43,
    MSK_DPAR_MIO_NEAR_TOL_REL_GAP      = 44,
    MSK_DPAR_MIO_REL_ADD_CUT_LIMITED   = 45,
    MSK_DPAR_MIO_TOL_ABS_GAP           = 46,
    MSK_DPAR_MIO_TOL_ABS_RELAX_INT     = 47,
    MSK_DPAR_MIO_TOL_REL_GAP           = 48,
    MSK_DPAR_MIO_TOL_REL_RELAX_INT     = 49,
    MSK_DPAR_MIO_TOL_X                 = 50,
    MSK_DPAR_NONCONVEX_TOL_FEAS        = 51,
    MSK_DPAR_NONCONVEX_TOL_OPT         = 52,
    MSK_DPAR_OPTIMIZER_MAX_TIME        = 53,
    MSK_DPAR_PRESOLVE_TOL_AIJ          = 54,
    MSK_DPAR_PRESOLVE_TOL_LIN_DEP      = 55,
    MSK_DPAR_PRESOLVE_TOL_S            = 56,
    MSK_DPAR_PRESOLVE_TOL_X            = 57,
    MSK_DPAR_SIMPLEX_ABS_TOL_PIV       = 58,
    MSK_DPAR_UPPER_OBJ_CUT             = 59,
    MSK_DPAR_UPPER_OBJ_CUT_FINITE_TRH  = 60
  );

(* Basis identification *)
const
  MSK_BI_ALWAYS                        = 1;
  MSK_BI_NO_ERROR                      = 2;
  MSK_BI_NEVER                         = 0;
  MSK_BI_IF_FEASIBLE                   = 3;
  MSK_BI_OTHER                         = 4;

(* Compression types *)
const
  MSK_COMPRESS_GZIP                    = 2;
  MSK_COMPRESS_NONE                    = 0;
  MSK_COMPRESS_FREE                    = 1;

(* Variable types *)
type
  MSKvariabletype =
  (
    MSK_VAR_TYPE_CONT                  = 0,
    MSK_VAR_TYPE_INT                   = 1
  );

(* Types of convexity checks. *)
const
  MSK_CHECK_CONVEXITY_SIMPLE           = 1;
  MSK_CHECK_CONVEXITY_NONE             = 0;

(* Starting point types *)
const
  MSK_STARTING_POINT_CONSTANT          = 1;
  MSK_STARTING_POINT_FREE              = 0;

(* Solution types *)
type
  MSKsoltype =
  (
    MSK_SOL_ITR                        = 0,
    MSK_SOL_BAS                        = 1,
    MSK_SOL_ITG                        = 2
  );

(* Integer values *)
const
  MSK_MAX_STR_LEN                      = 1024;
  MSK_LICENSE_BUFFER_LENGTH            = 20;

(* Status keys *)
type
  MSKstakey =
  (
    MSK_SK_UNK                         = 0,
    MSK_SK_BAS                         = 1,
    MSK_SK_SUPBAS                      = 2,
    MSK_SK_LOW                         = 3,
    MSK_SK_UPR                         = 4,
    MSK_SK_FIX                         = 5,
    MSK_SK_INF                         = 6
  );

(* Integer information items. *)
type
  MSKiinfitem =
  (
    MSK_IINF_BI_ITER                   = 0,
    MSK_IINF_CACHE_SIZE_L1             = 1,
    MSK_IINF_CACHE_SIZE_L2             = 2,
    MSK_IINF_CONCURRENT_FASTEST_OPTIMIZER = 3,
    MSK_IINF_CPU_TYPE                  = 4,
    MSK_IINF_INTPNT_FACTOR_NUM_NZ      = 5,
    MSK_IINF_INTPNT_FACTOR_NUM_OFFCOL  = 6,
    MSK_IINF_INTPNT_ITER               = 7,
    MSK_IINF_INTPNT_NUM_THREADS        = 8,
    MSK_IINF_INTPNT_SOLVE_DUAL         = 9,
    MSK_IINF_MIO_CONSTRUCT_SOLUTION    = 10,
    MSK_IINF_MIO_INITIAL_SOLUTION      = 11,
    MSK_IINF_MIO_NUM_ACTIVE_NODES      = 12,
    MSK_IINF_MIO_NUM_BRANCH            = 13,
    MSK_IINF_MIO_NUM_CUTS              = 14,
    MSK_IINF_MIO_NUM_INT_SOLUTIONS     = 15,
    MSK_IINF_MIO_NUM_INTPNT_ITER       = 16,
    MSK_IINF_MIO_NUM_RELAX             = 17,
    MSK_IINF_MIO_NUM_SIMPLEX_ITER      = 18,
    MSK_IINF_MIO_NUMCON                = 19,
    MSK_IINF_MIO_NUMINT                = 20,
    MSK_IINF_MIO_NUMVAR                = 21,
    MSK_IINF_MIO_TOTAL_NUM_BASIS_CUTS  = 22,
    MSK_IINF_MIO_TOTAL_NUM_BRANCH      = 23,
    MSK_IINF_MIO_TOTAL_NUM_CARDGUB_CUTS = 24,
    MSK_IINF_MIO_TOTAL_NUM_CLIQUE_CUTS = 25,
    MSK_IINF_MIO_TOTAL_NUM_COEF_REDC_CUTS = 26,
    MSK_IINF_MIO_TOTAL_NUM_CONTRA_CUTS = 27,
    MSK_IINF_MIO_TOTAL_NUM_CUTS        = 28,
    MSK_IINF_MIO_TOTAL_NUM_DISAGG_CUTS = 29,
    MSK_IINF_MIO_TOTAL_NUM_FLOW_COVER_CUTS = 30,
    MSK_IINF_MIO_TOTAL_NUM_GCD_CUTS    = 31,
    MSK_IINF_MIO_TOTAL_NUM_GOMORY_CUTS = 32,
    MSK_IINF_MIO_TOTAL_NUM_GUB_COVER_CUTS = 33,
    MSK_IINF_MIO_TOTAL_NUM_KNAPSUR_COVER_CUTS = 34,
    MSK_IINF_MIO_TOTAL_NUM_LATTICE_CUTS = 35,
    MSK_IINF_MIO_TOTAL_NUM_LIFT_CUTS   = 36,
    MSK_IINF_MIO_TOTAL_NUM_OBJ_CUTS    = 37,
    MSK_IINF_MIO_TOTAL_NUM_PLAN_LOC_CUTS = 38,
    MSK_IINF_MIO_TOTAL_NUM_RELAX       = 39,
    MSK_IINF_MIO_USER_OBJ_CUT          = 40,
    MSK_IINF_OPT_NUMCON                = 41,
    MSK_IINF_OPT_NUMVAR                = 42,
    MSK_IINF_OPTIMIZE_RESPONSE         = 43,
    MSK_IINF_RD_NUMANZ                 = 44,
    MSK_IINF_RD_NUMCON                 = 45,
    MSK_IINF_RD_NUMCONE                = 46,
    MSK_IINF_RD_NUMINTVAR              = 47,
    MSK_IINF_RD_NUMQ                   = 48,
    MSK_IINF_RD_NUMQNZ                 = 49,
    MSK_IINF_RD_NUMVAR                 = 50,
    MSK_IINF_RD_PROTYPE                = 51,
    MSK_IINF_SIM_DUAL_DEG_ITER         = 52,
    MSK_IINF_SIM_DUAL_HOTSTART         = 53,
    MSK_IINF_SIM_DUAL_HOTSTART_LU      = 54,
    MSK_IINF_SIM_DUAL_INF_ITER         = 55,
    MSK_IINF_SIM_DUAL_ITER             = 56,
    MSK_IINF_SIM_NUMCON                = 57,
    MSK_IINF_SIM_NUMVAR                = 58,
    MSK_IINF_SIM_PRIMAL_DEG_ITER       = 59,
    MSK_IINF_SIM_PRIMAL_HOTSTART       = 60,
    MSK_IINF_SIM_PRIMAL_HOTSTART_LU    = 61,
    MSK_IINF_SIM_PRIMAL_INF_ITER       = 62,
    MSK_IINF_SIM_PRIMAL_ITER           = 63,
    MSK_IINF_SIM_SOLVE_DUAL            = 64,
    MSK_IINF_SOL_BAS_PROSTA            = 65,
    MSK_IINF_SOL_BAS_SOLSTA            = 66,
    MSK_IINF_SOL_INT_PROSTA            = 67,
    MSK_IINF_SOL_INT_SOLSTA            = 68,
    MSK_IINF_SOL_ITR_PROSTA            = 69,
    MSK_IINF_SOL_ITR_SOLSTA            = 70,
    MSK_IINF_STO_NUM_A_CACHE_FLUSHES   = 71,
    MSK_IINF_STO_NUM_A_REALLOC         = 72,
    MSK_IINF_STO_NUM_A_TRANSPOSES      = 73
  );

(* XML writer output mode *)
type
  MSKxmlwriteroutputtype =
  (
    MSK_WRITE_XML_MODE_ROW             = 0,
    MSK_WRITE_XML_MODE_COL             = 1
  );

(* Optimizer types *)
const
  MSK_OPTIMIZER_INTPNT                 = 1;
  MSK_OPTIMIZER_CONCURRENT             = 9;
  MSK_OPTIMIZER_MIXED_INT              = 7;
  MSK_OPTIMIZER_DUAL_SIMPLEX           = 5;
  MSK_OPTIMIZER_FREE                   = 0;
  MSK_OPTIMIZER_CONIC                  = 2;
  MSK_OPTIMIZER_NONCONVEX              = 8;
  MSK_OPTIMIZER_QCONE                  = 3;
  MSK_OPTIMIZER_PRIMAL_SIMPLEX         = 4;
  MSK_OPTIMIZER_FREE_SIMPLEX           = 6;

(* CPU type *)
const
  MSK_CPU_POWERPC_G5                   = 8;
  MSK_CPU_INTEL_PM                     = 9;
  MSK_CPU_GENERIC                      = 1;
  MSK_CPU_UNKNOWN                      = 0;
  MSK_CPU_AMD_OPTERON                  = 7;
  MSK_CPU_INTEL_ITANIUM2               = 6;
  MSK_CPU_AMD_ATHLON                   = 4;
  MSK_CPU_HP_PARISC20                  = 5;
  MSK_CPU_INTEL_P4                     = 3;
  MSK_CPU_INTEL_P3                     = 2;
  MSK_CPU_INTEL_CORE2                  = 10;

(* Continuous mixed integer solution type *)
const
  MSK_MIO_CONT_SOL_ITG                 = 2;
  MSK_MIO_CONT_SOL_NONE                = 0;
  MSK_MIO_CONT_SOL_ROOT                = 1;
  MSK_MIO_CONT_SOL_ITG_REL             = 3;

(************************************************************)
(**  TYPES                                                 **)
(************************************************************)
type
  MSKenv_t  = pointer;
  MSKtask_t = pointer;
  MSKfile_t = pointer;
  MSKuserhandle_t = pointer;

  MSKintt   = Integer; (* int32 *)
  MSKlintt  = Integer; (* int32 - may become int64*)
  MSKidxt   = Integer; (* int32 *)
  MSKlidxt  = Integer; (* int32 - may become int64*)
  MSKrealt  = double;  (* 64 bit float *)

  AMSKtask_t = array[0..High(integer) div SizeOf(MSKtask_t)  - 1] of MSKtask_t;
  PMSKtask_t = ^ AMSKtask_t;

  AMSKrealt = array[0..High(integer) div SizeOf(double)  - 1] of double;
  PMSKrealt = ^ AMSKrealt;

  AMSKidxt  = array[0..High(integer) div SizeOf(MSKidxt)  - 1] of MSKidxt;
  AMSKlidxt = array[0..High(integer) div SizeOf(MSKlidxt) - 1] of MSKlidxt;
  AMSKintt  = array[0..High(integer) div SizeOf(MSKintt)  - 1] of MSKintt;
  AMSKlintt = array[0..High(integer) div SizeOf(MSKlintt) - 1] of MSKlintt;

  PMSKidxt  = ^ AMSKidxt;
  PMSKlidxt = ^ AMSKlidxt;
  PMSKintt  = ^ AMSKintt;
  PMSKlintt = ^ AMSKlintt;

  MSKcallbackfunc = function  ( task : MSKtask_t; usrptr : pointer; caller : MSKcallbackcode ) : Longint; stdcall;
  MSKstreamfunc   = procedure ( usrptr : pointer; str : PChar ); stdcall;
  MSKctrlcfunc    = function  ( usrptr : pointer ) : Longint; stdcall;
  MSKexitfunc     = procedure ( usrptr : pointer; file_ : PChar; line : Longint; msg : PChar ); stdcall;
  MSKresponsefunc = function  ( usrptr : pointer; r : MSKrescode; msg : PChar) : MSKrescode; stdcall;

  (* some dummy definitions *)
  MSKfreefunc = pointer;
  MSKmallocfunc = pointer;

(************************************************************)
(**  FUNCTIONS                                             **)
(************************************************************)
type
  TMSK_initbasissolve = function
      (task  : MSKtask_t;
       basis : PMSKidxt (* output only *)) : MSKrescode; stdcall;

  TMSK_solvewithbasis = function
      (task      : MSKtask_t;
       transp    : MSKintt;
       var numnz : MSKintt;
       sub       : PMSKidxt (* input/output *);
       val       : PMSKrealt (* input/output *)) : MSKrescode; stdcall;

  TMSK_append = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       num     : MSKintt) : MSKrescode; stdcall;

  TMSK_remove = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       num     : MSKintt;
       sub     : PMSKintt (* input only *)) : MSKrescode; stdcall;

  TMSK_appendcone = function
      (task     : MSKtask_t;
       conetype : MSKconetype;
       conepar  : MSKrealt;
       nummem   : MSKintt;
       submem   : PMSKidxt (* input only *)) : MSKrescode; stdcall;

  TMSK_removecone = function
      (task : MSKtask_t;
       k    : MSKidxt) : MSKrescode; stdcall;

  TMSK_appendvars = function
      (task  : MSKtask_t;
       num   : MSKintt;
       cval  : PMSKrealt (* input only *);
       aptrb : PMSKlidxt (* input only *);
       aptre : PMSKlidxt (* input only *);
       asub  : PMSKidxt (* input only *);
       aval  : PMSKrealt (* input only *);
       bkx   : PMSKintt (* input only *);
       blx   : PMSKrealt (* input only *);
       bux   : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_appendcons = function
      (task  : MSKtask_t;
       num   : MSKintt;
       aptrb : PMSKlidxt (* input only *);
       aptre : PMSKlidxt (* input only *);
       asub  : PMSKidxt (* input only *);
       aval  : PMSKrealt (* input only *);
       bkc   : PMSKintt (* input only *);
       blc   : PMSKrealt (* input only *);
       buc   : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_bktostr = function
      (task : MSKtask_t;
       bk   : MSKboundkey;
       str  : PChar) : MSKrescode; stdcall;

  TMSK_callbackcodetostr = function
      (code            : MSKcallbackcode;
       callbackcodestr : PChar) : MSKrescode; stdcall;

  TMSK_chgbound = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       i       : MSKidxt;
       lower   : MSKintt;
       finite  : MSKintt;
       value   : MSKrealt) : MSKrescode; stdcall;

  TMSK_conetypetostr = function
      (task     : MSKtask_t;
       conetype : MSKconetype;
       str      : PChar) : MSKrescode; stdcall;

  TMSK_deletetask = function (var task : MSKtask_t) : MSKrescode; stdcall;
  (* not translated: MSK_exceptiontask *)
  (* not translated: MSK_echotask *)
  TMSK_freetask = procedure
      (task   : MSKtask_t;
       buffer : pointer (* input only *)); stdcall;

  TMSK_freedbgtask = procedure
      (task   : MSKtask_t;
       buffer : pointer (* input only *);
       file_  : PChar;
       line   : cardinal); stdcall;

  TMSK_getaij = function
      (task    : MSKtask_t;
       i       : MSKidxt;
       j       : MSKidxt;
       out aij : MSKrealt) : MSKrescode; stdcall;

  TMSK_getapiecenumnz = function
      (task      : MSKtask_t;
       firsti    : MSKidxt;
       lasti     : MSKidxt;
       firstj    : MSKidxt;
       lastj     : MSKidxt;
       out numnz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getavecnumnz = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       i       : MSKidxt;
       out nzj : MSKintt) : MSKrescode; stdcall;

  TMSK_getavec = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       i       : MSKidxt;
       out nzi : MSKintt;
       subi    : PMSKidxt (* output only *);
       vali    : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getaslicenumnz = function
      (task      : MSKtask_t;
       accmode   : MSKaccmode;
       first     : MSKidxt;
       last      : MSKidxt;
       out numnz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getaslice = function
      (task     : MSKtask_t;
       accmode  : MSKaccmode;
       first    : MSKidxt;
       last     : MSKidxt;
       maxnumnz : MSKlintt;
       var surp : MSKlintt;
       ptrb     : PMSKlidxt (* output only *);
       ptre     : PMSKlidxt (* output only *);
       sub      : PMSKidxt (* output only *);
       val      : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getaslicetrip = function
      (task     : MSKtask_t;
       accmode  : MSKaccmode;
       first    : MSKidxt;
       last     : MSKidxt;
       maxnumnz : MSKlintt;
       var surp : MSKlintt;
       subi     : PMSKidxt (* output only *);
       subj     : PMSKidxt (* output only *);
       val      : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getbound = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       i       : MSKidxt;
       out bk  : MSKboundkey;
       out bl  : MSKrealt;
       out bu  : MSKrealt) : MSKrescode; stdcall;

  TMSK_getboundslice = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       first   : MSKidxt;
       last    : MSKidxt;
       bk      : PMSKintt (* output only *);
       bl      : PMSKrealt (* output only *);
       bu      : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_putboundslice = function
      (task  : MSKtask_t;
       con   : MSKaccmode;
       first : MSKidxt;
       last  : MSKidxt;
       bk    : PMSKintt (* input only *);
       bl    : PMSKrealt (* input only *);
       bu    : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_getc = function
      (task : MSKtask_t;
       c    : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getcallbackfunc = function
      (task       : MSKtask_t;
       out func   : MSKcallbackfunc;
       out handle : MSKuserhandle_t) : MSKrescode; stdcall;

  TMSK_getsolutionincallback = function
      (task       : MSKtask_t;
       where      : MSKcallbackcode;
       whichsol   : MSKsoltype;
       out prosta : MSKprosta;
       out solsta : MSKsolsta;
       skc        : PMSKintt (* output only *);
       skx        : PMSKintt (* output only *);
       skn        : PMSKintt (* output only *);
       xc         : PMSKrealt (* output only *);
       xx         : PMSKrealt (* output only *);
       y          : PMSKrealt (* output only *);
       slc        : PMSKrealt (* output only *);
       suc        : PMSKrealt (* output only *);
       slx        : PMSKrealt (* output only *);
       sux        : PMSKrealt (* output only *);
       snx        : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getcfix = function
      (task     : MSKtask_t;
       out cfix : MSKrealt) : MSKrescode; stdcall;

  TMSK_getcone = function
      (task         : MSKtask_t;
       k            : MSKidxt;
       out conetype : MSKconetype;
       out conepar  : MSKrealt;
       out nummem   : MSKintt;
       submem       : PMSKidxt (* output only *)) : MSKrescode; stdcall;

  TMSK_getconeinfo = function
      (task         : MSKtask_t;
       k            : MSKidxt;
       out conetype : MSKconetype;
       out conepar  : MSKrealt;
       out nummem   : MSKintt) : MSKrescode; stdcall;

  TMSK_getcslice = function
      (task  : MSKtask_t;
       first : MSKidxt;
       last  : MSKidxt;
       c     : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getdouinf = function
      (task       : MSKtask_t;
       whichdinf  : MSKdinfitem;
       out dvalue : MSKrealt) : MSKrescode; stdcall;

  TMSK_getdouparam = function
      (task         : MSKtask_t;
       param        : MSKdparam;
       out parvalue : MSKrealt) : MSKrescode; stdcall;

  TMSK_getdualobj = function
      (task        : MSKtask_t;
       whichsol    : MSKsoltype;
       out dualobj : MSKrealt) : MSKrescode; stdcall;

  TMSK_getenv = function
      (task    : MSKtask_t;
       out env : MSKenv_t) : MSKrescode; stdcall;

  TMSK_getinfindex = function
      (task         : MSKtask_t;
       inftype      : MSKinftype;
       infname      : PChar;
       out infindex : MSKintt) : MSKrescode; stdcall;

  TMSK_getinfmax = function
      (task    : MSKtask_t;
       inftype : MSKinftype;
       infmax  : PMSKintt (* output only *)) : MSKrescode; stdcall;

  TMSK_getinfname = function
      (task     : MSKtask_t;
       inftype  : MSKinftype;
       whichinf : MSKintt;
       infname  : PChar) : MSKrescode; stdcall;

  TMSK_getintinf = function
      (task       : MSKtask_t;
       whichiinf  : MSKiinfitem;
       out ivalue : MSKintt) : MSKrescode; stdcall;

  TMSK_getintparam = function
      (task         : MSKtask_t;
       param        : MSKiparam;
       out parvalue : MSKintt) : MSKrescode; stdcall;

  TMSK_getmaxnamelen = function
      (task       : MSKtask_t;
       out maxlen : cardinal) : MSKrescode; stdcall;

  TMSK_getmaxnumanz = function
      (task          : MSKtask_t;
       out maxnumanz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getmaxnumcon = function
      (task          : MSKtask_t;
       out maxnumcon : MSKintt) : MSKrescode; stdcall;

  TMSK_getmaxnumvar = function
      (task          : MSKtask_t;
       out maxnumvar : MSKintt) : MSKrescode; stdcall;

  TMSK_getnadouinf = function
      (task       : MSKtask_t;
       whichdinf  : PChar;
       out dvalue : MSKrealt) : MSKrescode; stdcall;

  TMSK_getnadouparam = function
      (task         : MSKtask_t;
       paramname    : PChar;
       out parvalue : MSKrealt) : MSKrescode; stdcall;

  TMSK_getnaintinf = function
      (task        : MSKtask_t;
       infitemname : PChar;
       out ivalue  : MSKintt) : MSKrescode; stdcall;

  TMSK_getnaintparam = function
      (task         : MSKtask_t;
       paramname    : PChar;
       out parvalue : MSKintt) : MSKrescode; stdcall;

  TMSK_getname = function
      (task      : MSKtask_t;
       whichitem : MSKproblemitem;
       i         : MSKidxt;
       maxlen    : cardinal;
       out len   : cardinal;
       name      : PChar) : MSKrescode; stdcall;

  TMSK_getvarname = function
      (task   : MSKtask_t;
       i      : MSKidxt;
       maxlen : cardinal;
       name   : PChar) : MSKrescode; stdcall;

  TMSK_getconname = function
      (task   : MSKtask_t;
       i      : MSKidxt;
       maxlen : cardinal;
       name   : PChar) : MSKrescode; stdcall;

  TMSK_getnameindex = function
      (task      : MSKtask_t;
       whichitem : MSKproblemitem;
       name      : PChar;
       out asgn  : MSKintt;
       out index : MSKidxt) : MSKrescode; stdcall;

  TMSK_getnastrparam = function
      (task      : MSKtask_t;
       paramname : PChar;
       maxlen    : cardinal;
       out len   : cardinal;
       parvalue  : PChar) : MSKrescode; stdcall;

  TMSK_getnumanz = function
      (task       : MSKtask_t;
       out numanz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getnumcon = function
      (task       : MSKtask_t;
       out numcon : MSKintt) : MSKrescode; stdcall;

  TMSK_getnumcone = function
      (task        : MSKtask_t;
       out numcone : MSKintt) : MSKrescode; stdcall;

  TMSK_getnumconemem = function
      (task       : MSKtask_t;
       k          : MSKidxt;
       out nummem : MSKintt) : MSKrescode; stdcall;

  TMSK_getnumintvar = function
      (task          : MSKtask_t;
       out numintvar : MSKintt) : MSKrescode; stdcall;

  TMSK_getnumparam = function
      (task         : MSKtask_t;
       partype      : MSKparametertype;
       out numparam : MSKintt) : MSKrescode; stdcall;

  TMSK_getnumqconnz = function
      (task        : MSKtask_t;
       i           : MSKidxt;
       out numqcnz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getnumqobjnz = function
      (task        : MSKtask_t;
       out numqonz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getnumvar = function
      (task       : MSKtask_t;
       out numvar : MSKintt) : MSKrescode; stdcall;

  TMSK_getobjname = function
      (task    : MSKtask_t;
       maxlen  : cardinal;
       out len : cardinal;
       objname : PChar) : MSKrescode; stdcall;

  TMSK_getparamname = function
      (task    : MSKtask_t;
       partype : MSKparametertype;
       param   : MSKintt;
       parname : PChar) : MSKrescode; stdcall;

  TMSK_getparammax = function
      (task     : MSKtask_t;
       partype  : MSKparametertype;
       parammax : PMSKintt (* input only *)) : MSKrescode; stdcall;

  TMSK_getprimalobj = function
      (task          : MSKtask_t;
       whichsol      : MSKsoltype;
       out primalobj : MSKrealt) : MSKrescode; stdcall;

  TMSK_getprobtype = function
      (task         : MSKtask_t;
       out probtype : MSKproblemtype) : MSKrescode; stdcall;

  TMSK_getqconk = function
      (task        : MSKtask_t;
       k           : MSKidxt;
       maxnumqcnz  : MSKlintt;
       var qcsurp  : MSKlintt;
       out numqcnz : MSKlintt;
       qcsubi      : PMSKidxt (* output only *);
       qcsubj      : PMSKidxt (* output only *);
       qcval       : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getqobj = function
      (task        : MSKtask_t;
       maxnumqonz  : MSKlintt;
       var qosurp  : MSKlintt;
       out numqonz : MSKlintt;
       qosubi      : PMSKidxt (* output only *);
       qosubj      : PMSKidxt (* output only *);
       qoval       : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getqobjij = function
      (task     : MSKtask_t;
       i        : MSKidxt;
       j        : MSKidxt;
       out qoij : MSKrealt) : MSKrescode; stdcall;

  TMSK_getsolution = function
      (task       : MSKtask_t;
       whichsol   : MSKsoltype;
       out prosta : MSKprosta;
       out solsta : MSKsolsta;
       skc        : PMSKintt (* output only *);
       skx        : PMSKintt (* output only *);
       skn        : PMSKintt (* output only *);
       xc         : PMSKrealt (* output only *);
       xx         : PMSKrealt (* output only *);
       y          : PMSKrealt (* output only *);
       slc        : PMSKrealt (* output only *);
       suc        : PMSKrealt (* output only *);
       slx        : PMSKrealt (* output only *);
       sux        : PMSKrealt (* output only *);
       snx        : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getsolutioni = function
      (task     : MSKtask_t;
       accmode  : MSKaccmode;
       i        : MSKidxt;
       whichsol : MSKsoltype;
       out sk   : MSKstakey;
       out x    : MSKrealt;
       out sl   : MSKrealt;
       out su   : MSKrealt;
       out sn   : MSKrealt) : MSKrescode; stdcall;

  TMSK_getsolutioninf = function
      (task          : MSKtask_t;
       whichsol      : MSKsoltype;
       out prosta    : MSKprosta;
       out solsta    : MSKsolsta;
       out primalobj : MSKrealt;
       out maxpbi    : MSKrealt;
       out maxpcni   : MSKrealt;
       out maxpeqi   : MSKrealt;
       out maxinti   : MSKrealt;
       out dualobj   : MSKrealt;
       out maxdbi    : MSKrealt;
       out maxdcni   : MSKrealt;
       out maxdeqi   : MSKrealt) : MSKrescode; stdcall;

  TMSK_getsolutionstatus = function
      (task       : MSKtask_t;
       whichsol   : MSKsoltype;
       out prosta : MSKprosta;
       out solsta : MSKsolsta) : MSKrescode; stdcall;

  TMSK_getsolutionslice = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype;
       solitem  : MSKsolitem;
       first    : MSKidxt;
       last     : MSKidxt;
       values   : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getsolutionstatuskeyslice = function
      (task     : MSKtask_t;
       accmode  : MSKaccmode;
       whichsol : MSKsoltype;
       first    : MSKidxt;
       last     : MSKidxt;
       sk       : PMSKintt (* output only *)) : MSKrescode; stdcall;

  TMSK_getreducedcosts = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype;
       first    : MSKidxt;
       last     : MSKidxt;
       redcosts : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_getstrparam = function
      (task     : MSKtask_t;
       param    : MSKsparam;
       maxlen   : cardinal;
       out len  : cardinal;
       parvalue : PChar) : MSKrescode; stdcall;

  TMSK_getstrparamal = function
      (task      : MSKtask_t;
       param     : MSKsparam;
       numaddchr : cardinal;
       value     : PPChar (* input/output *)) : MSKrescode; stdcall;

  TMSK_getnastrparamal = function
      (task      : MSKtask_t;
       paramname : PChar;
       numaddchr : cardinal;
       value     : PPChar (* input/output *)) : MSKrescode; stdcall;

  TMSK_getsymbcon = function
      (task      : MSKtask_t;
       i         : MSKidxt;
       maxlen    : cardinal;
       name      : PChar;
       out value : MSKintt) : MSKrescode; stdcall;

  TMSK_gettaskname = function
      (task     : MSKtask_t;
       maxlen   : cardinal;
       out len  : cardinal;
       taskname : PChar) : MSKrescode; stdcall;

  TMSK_getvartype = function
      (task        : MSKtask_t;
       j           : MSKidxt;
       out vartype : MSKvariabletype) : MSKrescode; stdcall;

  TMSK_getvartypelist = function
      (task    : MSKtask_t;
       num     : MSKintt;
       subj    : PMSKidxt (* input only *);
       vartype : PMSKintt (* output only *)) : MSKrescode; stdcall;

  TMSK_inputdata = function
      (task      : MSKtask_t;
       maxnumcon : MSKintt;
       maxnumvar : MSKintt;
       numcon    : MSKintt;
       numvar    : MSKintt;
       c         : PMSKrealt (* input only *);
       cfix      : MSKrealt;
       aptrb     : PMSKlidxt (* input only *);
       aptre     : PMSKlidxt (* input only *);
       asub      : PMSKidxt (* input only *);
       aval      : PMSKrealt (* input only *);
       bkc       : PMSKintt (* input only *);
       blc       : PMSKrealt (* input only *);
       buc       : PMSKrealt (* input only *);
       bkx       : PMSKintt (* input only *);
       blx       : PMSKrealt (* input only *);
       bux       : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_isdouparname = function
      (task      : MSKtask_t;
       parname   : PChar;
       out param : MSKdparam) : MSKrescode; stdcall;

  TMSK_isintparname = function
      (task      : MSKtask_t;
       parname   : PChar;
       out param : MSKiparam) : MSKrescode; stdcall;

  TMSK_isstrparname = function
      (task      : MSKtask_t;
       parname   : PChar;
       out param : MSKsparam) : MSKrescode; stdcall;

  TMSK_linkfiletotaskstream = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype;
       filename    : PChar;
       append      : MSKintt) : MSKrescode; stdcall;

  TMSK_linkfunctotaskstream = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype;
       handle      : MSKuserhandle_t;
       func        : MSKstreamfunc) : MSKrescode; stdcall;

  TMSK_unlinkfuncfromtaskstream = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype) : MSKrescode; stdcall;

  TMSK_clonetask = function
      (task           : MSKtask_t;
       out clonedtask : MSKtask_t) : MSKrescode; stdcall;

  TMSK_relaxprimal = function
      (task            : MSKtask_t;
       out relaxedtask : MSKtask_t;
       wlc             : PMSKrealt (* input/output *);
       wuc             : PMSKrealt (* input/output *);
       wlx             : PMSKrealt (* input/output *);
       wux             : PMSKrealt (* input/output *)) : MSKrescode; stdcall;

  TMSK_optimizeconcurrent = function
      (task      : MSKtask_t;
       taskarray : PMSKtask_t (* input only *);
       num       : MSKintt) : MSKrescode; stdcall;

  TMSK_checkdata = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_optimize = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_optimizetrm = function
      (task        : MSKtask_t;
       out trmcode : MSKrescode) : MSKrescode; stdcall;

  TMSK_printdata = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype;
       firsti      : MSKidxt;
       lasti       : MSKidxt;
       firstj      : MSKidxt;
       lastj       : MSKidxt;
       firstk      : MSKidxt;
       lastk       : MSKidxt;
       c           : MSKintt;
       qo          : MSKintt;
       a           : MSKintt;
       qc          : MSKintt;
       bc          : MSKintt;
       bx          : MSKintt;
       vartype     : MSKintt;
       cones       : MSKintt) : MSKrescode; stdcall;

  TMSK_printparam = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_probtypetostr = function
      (task     : MSKtask_t;
       probtype : MSKproblemtype;
       str      : PChar) : MSKrescode; stdcall;

  TMSK_prostatostr = function
      (task   : MSKtask_t;
       prosta : MSKprosta;
       str    : PChar) : MSKrescode; stdcall;

  TMSK_putresponsefunc = function
      (task         : MSKtask_t;
       responsefunc : MSKresponsefunc;
       handle       : MSKuserhandle_t) : MSKrescode; stdcall;

  TMSK_commitchanges = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_putaij = function
      (task : MSKtask_t;
       i    : MSKidxt;
       j    : MSKidxt;
       aij  : MSKrealt) : MSKrescode; stdcall;

  TMSK_putaijlist = function
      (task  : MSKtask_t;
       num   : MSKintt;
       subi  : PMSKidxt (* input only *);
       subj  : PMSKidxt (* input only *);
       valij : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putavec = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       i       : MSKidxt;
       nzi     : MSKlintt;
       asub    : PMSKidxt (* input only *);
       aval    : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putaveclist = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       num     : MSKlintt;
       sub     : PMSKidxt (* input only *);
       ptrb    : PMSKlidxt (* input only *);
       ptre    : PMSKlidxt (* input only *);
       asub    : PMSKidxt (* input only *);
       aval    : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putbound = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       i       : MSKidxt;
       bk      : MSKboundkey;
       bl      : MSKrealt;
       bu      : MSKrealt) : MSKrescode; stdcall;

  TMSK_putboundlist = function
      (task    : MSKtask_t;
       accmode : MSKaccmode;
       num     : MSKlintt;
       sub     : PMSKidxt (* input only *);
       bk      : PMSKintt (* input only *);
       bl      : PMSKrealt (* input only *);
       bu      : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putcallbackfunc = function
      (task   : MSKtask_t;
       func   : MSKcallbackfunc;
       handle : MSKuserhandle_t) : MSKrescode; stdcall;

  TMSK_putcfix = function
      (task : MSKtask_t;
       cfix : MSKrealt) : MSKrescode; stdcall;

  TMSK_putcj = function
      (task : MSKtask_t;
       j    : MSKidxt;
       cj   : MSKrealt) : MSKrescode; stdcall;

  TMSK_putobjsense = function
      (task  : MSKtask_t;
       sense : MSKobjsense) : MSKrescode; stdcall;

  TMSK_getobjsense = function
      (task      : MSKtask_t;
       out sense : MSKobjsense) : MSKrescode; stdcall;

  TMSK_putclist = function
      (task : MSKtask_t;
       num  : MSKintt;
       subj : PMSKidxt (* input only *);
       val  : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putcone = function
      (task     : MSKtask_t;
       k        : MSKidxt;
       conetype : MSKconetype;
       conepar  : MSKrealt;
       nummem   : MSKintt;
       submem   : PMSKidxt (* input only *)) : MSKrescode; stdcall;

  TMSK_putdouparam = function
      (task     : MSKtask_t;
       param    : MSKdparam;
       parvalue : MSKrealt) : MSKrescode; stdcall;

  TMSK_putintparam = function
      (task     : MSKtask_t;
       param    : MSKiparam;
       parvalue : MSKintt) : MSKrescode; stdcall;

  TMSK_putmaxnumcon = function
      (task      : MSKtask_t;
       maxnumcon : MSKintt) : MSKrescode; stdcall;

  TMSK_putmaxnumcone = function
      (task       : MSKtask_t;
       maxnumcone : MSKintt) : MSKrescode; stdcall;

  TMSK_getmaxnumcone = function
      (task           : MSKtask_t;
       out maxnumcone : MSKintt) : MSKrescode; stdcall;

  TMSK_putmaxnumvar = function
      (task      : MSKtask_t;
       maxnumvar : MSKintt) : MSKrescode; stdcall;

  TMSK_putmaxnumanz = function
      (task      : MSKtask_t;
       maxnumanz : MSKlintt) : MSKrescode; stdcall;

  TMSK_putmaxnumqnz = function
      (task      : MSKtask_t;
       maxnumqnz : MSKlintt) : MSKrescode; stdcall;

  TMSK_getmaxnumqnz = function
      (task          : MSKtask_t;
       out maxnumqnz : MSKintt) : MSKrescode; stdcall;

  TMSK_putnadouparam = function
      (task      : MSKtask_t;
       paramname : PChar;
       parvalue  : MSKrealt) : MSKrescode; stdcall;

  TMSK_putnaintparam = function
      (task      : MSKtask_t;
       paramname : PChar;
       parvalue  : MSKintt) : MSKrescode; stdcall;

  TMSK_putname = function
      (task      : MSKtask_t;
       whichitem : MSKproblemitem;
       i         : MSKidxt;
       name      : PChar) : MSKrescode; stdcall;

  TMSK_putnastrparam = function
      (task      : MSKtask_t;
       paramname : PChar;
       parvalue  : PChar) : MSKrescode; stdcall;

  (* not translated: MSK_putnlfunc *)
  (* not translated: MSK_getnlfunc *)
  TMSK_putobjname = function
      (task    : MSKtask_t;
       objname : PChar) : MSKrescode; stdcall;

  TMSK_putparam = function
      (task     : MSKtask_t;
       parname  : PChar;
       parvalue : PChar) : MSKrescode; stdcall;

  TMSK_putqcon = function
      (task    : MSKtask_t;
       numqcnz : MSKlintt;
       qcsubk  : PMSKidxt (* input only *);
       qcsubi  : PMSKidxt (* input only *);
       qcsubj  : PMSKidxt (* input only *);
       qcval   : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putqconk = function
      (task    : MSKtask_t;
       k       : MSKidxt;
       numqcnz : MSKlintt;
       qcsubi  : PMSKidxt (* input only *);
       qcsubj  : PMSKintt (* input only *);
       qcval   : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putqobj = function
      (task    : MSKtask_t;
       numqonz : MSKlintt;
       qosubi  : PMSKidxt (* input only *);
       qosubj  : PMSKidxt (* input only *);
       qoval   : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putqobjij = function
      (task : MSKtask_t;
       i    : MSKidxt;
       j    : MSKidxt;
       qoij : MSKrealt) : MSKrescode; stdcall;

  TMSK_makesolutionstatusunknown = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype) : MSKrescode; stdcall;

  TMSK_putsolution = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype;
       skc      : PMSKintt (* input only *);
       skx      : PMSKintt (* input only *);
       skn      : PMSKintt (* input only *);
       xc       : PMSKrealt (* input only *);
       xx       : PMSKrealt (* input only *);
       y        : PMSKrealt (* input only *);
       slc      : PMSKrealt (* input only *);
       suc      : PMSKrealt (* input only *);
       slx      : PMSKrealt (* input only *);
       sux      : PMSKrealt (* input only *);
       snx      : PMSKrealt (* input only *)) : MSKrescode; stdcall;

  TMSK_putsolutioni = function
      (task     : MSKtask_t;
       accmode  : MSKaccmode;
       i        : MSKidxt;
       whichsol : MSKsoltype;
       sk       : MSKstakey;
       x        : MSKrealt;
       sl       : MSKrealt;
       su       : MSKrealt;
       sn       : MSKrealt) : MSKrescode; stdcall;

  TMSK_putsolutionyi = function
      (task     : MSKtask_t;
       i        : MSKidxt;
       whichsol : MSKsoltype;
       y        : MSKrealt) : MSKrescode; stdcall;

  TMSK_putstrparam = function
      (task     : MSKtask_t;
       param    : MSKsparam;
       parvalue : PChar) : MSKrescode; stdcall;

  TMSK_puttaskname = function
      (task     : MSKtask_t;
       taskname : PChar) : MSKrescode; stdcall;

  TMSK_putvartype = function
      (task    : MSKtask_t;
       j       : MSKidxt;
       vartype : MSKvariabletype) : MSKrescode; stdcall;

  TMSK_putvartypelist = function
      (task    : MSKtask_t;
       num     : MSKintt;
       subj    : PMSKidxt (* input only *);
       vartype : PMSKintt (* input only *)) : MSKrescode; stdcall;

  TMSK_putvarbranchorder = function
      (task      : MSKtask_t;
       j         : MSKidxt;
       priority  : MSKintt;
       direction : MSKintt) : MSKrescode; stdcall;

  TMSK_getvarbranchorder = function
      (task          : MSKtask_t;
       j             : MSKidxt;
       out priority  : MSKintt;
       out direction : MSKintt) : MSKrescode; stdcall;

  TMSK_getvarbranchpri = function
      (task         : MSKtask_t;
       j            : MSKidxt;
       out priority : MSKintt) : MSKrescode; stdcall;

  TMSK_getvarbranchdir = function
      (task          : MSKtask_t;
       j             : MSKidxt;
       out direction : MSKintt) : MSKrescode; stdcall;

  TMSK_readdata = function
      (task     : MSKtask_t;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_readparamfile = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_readsolution = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_readsummary = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype) : MSKrescode; stdcall;

  TMSK_resizetask = function
      (task       : MSKtask_t;
       maxnumcon  : MSKintt;
       maxnumvar  : MSKintt;
       maxnumcone : MSKintt;
       maxnumanz  : MSKlintt;
       maxnumqnz  : MSKlintt) : MSKrescode; stdcall;

  TMSK_checkmemtask = function
      (task  : MSKtask_t;
       file_ : PChar;
       line  : MSKintt) : MSKrescode; stdcall;

  TMSK_getmemusagetask = function
      (task          : MSKtask_t;
       out meminuse  : cardinal;
       out maxmemuse : cardinal) : MSKrescode; stdcall;

  TMSK_setdefaults = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_sktostr = function
      (task : MSKtask_t;
       sk   : MSKintt;
       str  : PChar) : MSKrescode; stdcall;

  TMSK_solstatostr = function
      (task   : MSKtask_t;
       solsta : MSKsolsta;
       str    : PChar) : MSKrescode; stdcall;

  TMSK_solutiondef = function
      (task      : MSKtask_t;
       whichsol  : MSKsoltype;
       out isdef : MSKintt) : MSKrescode; stdcall;

  TMSK_deletesolution = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype) : MSKrescode; stdcall;

  TMSK_undefsolution = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype) : MSKrescode; stdcall;

  TMSK_startstat = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_stopstat = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_appendstat = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_solutionsummary = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype) : MSKrescode; stdcall;

  TMSK_strduptask = function
      (task : MSKtask_t;
       str  : PChar) : PChar; stdcall;

  TMSK_strdupdbgtask = function
      (task  : MSKtask_t;
       str   : PChar;
       file_ : PChar;
       line  : cardinal) : PChar; stdcall;

  TMSK_strtoconetype = function
      (task         : MSKtask_t;
       str          : PChar;
       out conetype : MSKconetype) : MSKrescode; stdcall;

  TMSK_strtosk = function
      (task   : MSKtask_t;
       str    : PChar;
       out sk : MSKintt) : MSKrescode; stdcall;

  TMSK_whichparam = function
      (task        : MSKtask_t;
       parname     : PChar;
       out partype : MSKparametertype;
       out param   : MSKintt) : MSKrescode; stdcall;

  TMSK_writedata = function
      (task     : MSKtask_t;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_readbranchpriorities = function
      (task     : MSKtask_t;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_writebranchpriorities = function
      (task     : MSKtask_t;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_writeparamfile = function
      (task     : MSKtask_t;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_getinfeasiblesubproblem = function
      (task        : MSKtask_t;
       whichsol    : MSKsoltype;
       out inftask : MSKtask_t) : MSKrescode; stdcall;

  TMSK_writesolution = function
      (task     : MSKtask_t;
       whichsol : MSKsoltype;
       filename : PChar) : MSKrescode; stdcall;

  TMSK_primalsensitivity = function
      (task        : MSKtask_t;
       numi        : MSKlintt;
       subi        : PMSKidxt (* input only *);
       marki       : PMSKintt (* input only *);
       numj        : MSKlintt;
       subj        : PMSKidxt (* input only *);
       markj       : PMSKintt (* input only *);
       leftpricei  : PMSKrealt (* output only *);
       rightpricei : PMSKrealt (* output only *);
       leftrangei  : PMSKrealt (* output only *);
       rightrangei : PMSKrealt (* output only *);
       leftpricej  : PMSKrealt (* output only *);
       rightpricej : PMSKrealt (* output only *);
       leftrangej  : PMSKrealt (* output only *);
       rightrangej : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_sensitivityreport = function
      (task        : MSKtask_t;
       whichstream : MSKstreamtype) : MSKrescode; stdcall;

  TMSK_dualsensitivity = function
      (task        : MSKtask_t;
       numj        : MSKlintt;
       subj        : PMSKidxt (* input only *);
       leftpricej  : PMSKrealt (* output only *);
       rightpricej : PMSKrealt (* output only *);
       leftrangej  : PMSKrealt (* output only *);
       rightrangej : PMSKrealt (* output only *)) : MSKrescode; stdcall;

  TMSK_checkconvexity = function (task : MSKtask_t) : MSKrescode; stdcall;
  TMSK_getlasterror = function
      (task            : MSKtask_t;
       out lastrescode : MSKrescode;
       maxlen          : cardinal;
       out lastmsglen  : cardinal;
       lastmsg         : PChar) : MSKrescode; stdcall;

  TMSK_isinfinity = function (value : MSKrealt) : MSKintt; stdcall;
  TMSK_getbuildinfo = function
      (buildstate : PChar;
       builddate  : PChar;
       buildtool  : PChar) : MSKrescode; stdcall;

  TMSK_getresponseclass = function
      (r      : MSKrescode;
       out rc : MSKrescodetype) : MSKrescode; stdcall;

  TMSK_deleteenv = function (var env : MSKenv_t) : MSKrescode; stdcall;
  (* not translated: MSK_echoenv *)
  TMSK_echointro = function
      (env     : MSKenv_t;
       longver : MSKintt) : MSKrescode; stdcall;

  TMSK_freeenv = procedure
      (env    : MSKenv_t;
       buffer : pointer (* input only *)); stdcall;

  TMSK_freedbgenv = procedure
      (env    : MSKenv_t;
       buffer : pointer (* input only *);
       file_  : PChar;
       line   : cardinal); stdcall;

  TMSK_getcodedisc = function
      (code    : MSKrescode;
       symname : PChar;
       str     : PChar) : MSKrescode; stdcall;

  TMSK_getsymbcondim = function
      (env        : MSKenv_t;
       out num    : MSKintt;
       out maxlen : cardinal) : MSKrescode; stdcall;

  TMSK_getversion = function
      (out major    : MSKintt;
       out minor    : MSKintt;
       out build    : MSKintt;
       out revision : MSKintt) : MSKrescode; stdcall;

  TMSK_checkversion = function
      (env      : MSKenv_t;
       major    : MSKintt;
       minor    : MSKintt;
       build    : MSKintt;
       revision : MSKintt) : MSKrescode; stdcall;

  TMSK_iparvaltosymnam = function
      (env          : MSKenv_t;
       whichparam   : MSKiparam;
       whichvalue   : MSKintt;
       symbolicname : PChar) : MSKrescode; stdcall;

  TMSK_linkfiletoenvstream = function
      (env         : MSKenv_t;
       whichstream : MSKstreamtype;
       filename    : PChar;
       append      : MSKintt) : MSKrescode; stdcall;

  TMSK_linkfunctoenvstream = function
      (env         : MSKenv_t;
       whichstream : MSKstreamtype;
       handle      : MSKuserhandle_t;
       func        : MSKstreamfunc) : MSKrescode; stdcall;

  TMSK_unlinkfuncfromenvstream = function
      (env         : MSKenv_t;
       whichstream : MSKstreamtype) : MSKrescode; stdcall;

  TMSK_makeenv = function
      (out env   : MSKenv_t;
       usrptr    : MSKuserhandle_t;
       usrmalloc : MSKmallocfunc;
       usrfree   : MSKfreefunc;
       dbgfile   : PChar) : MSKrescode; stdcall;

  TMSK_initenv = function (env : MSKenv_t) : MSKrescode; stdcall;
  TMSK_getglbdllname = function
      (env         : MSKenv_t;
       sizedllname : cardinal;
       dllname     : PChar) : MSKrescode; stdcall;

  TMSK_putdllpath = function
      (env     : MSKenv_t;
       dllpath : PChar) : MSKrescode; stdcall;

  TMSK_putlicensedefaults = function
      (env         : MSKenv_t;
       licensefile : PChar;
       licensebuf  : PMSKintt (* input only *);
       licwait     : MSKintt;
       licdebug    : MSKintt) : MSKrescode; stdcall;

  TMSK_putkeepdlls = function
      (env      : MSKenv_t;
       keepdlls : MSKintt) : MSKrescode; stdcall;

  TMSK_putcpudefaults = function
      (env     : MSKenv_t;
       cputype : MSKintt;
       sizel1  : MSKintt;
       sizel2  : MSKintt) : MSKrescode; stdcall;

  TMSK_maketask = function
      (env       : MSKenv_t;
       maxnumcon : MSKintt;
       maxnumvar : MSKintt;
       out task  : MSKtask_t) : MSKrescode; stdcall;

  TMSK_makeemptytask = function
      (env      : MSKenv_t;
       out task : MSKtask_t) : MSKrescode; stdcall;

  TMSK_putctrlcfunc = function
      (env       : MSKenv_t;
       ctrlcfunc : MSKctrlcfunc;
       handle    : MSKuserhandle_t) : MSKrescode; stdcall;

  TMSK_putexitfunc = function
      (env      : MSKenv_t;
       exitfunc : MSKexitfunc;
       handle   : MSKuserhandle_t) : MSKrescode; stdcall;

  TMSK_replacefileext = procedure
      (filename     : PChar;
       newextension : PChar); stdcall;

  (* not translated: MSK_utf8towchar *)
  (* not translated: MSK_wchartoutf8 *)
  TMSK_checkmemenv = function
      (env   : MSKenv_t;
       file_ : PChar;
       line  : MSKintt) : MSKrescode; stdcall;

  TMSK_strdupenv = function
      (env : MSKenv_t;
       str : PChar) : PChar; stdcall;

  TMSK_strdupdbgenv = function
      (env   : MSKenv_t;
       str   : PChar;
       file_ : PChar;
       line  : cardinal) : PChar; stdcall;

  TMSK_symnamtovalue = function
      (name  : PChar;
       value : PChar) : MSKintt; stdcall;


var
  MSK_initbasissolve            : TMSK_initbasissolve = nil;
  MSK_solvewithbasis            : TMSK_solvewithbasis = nil;
  MSK_append                    : TMSK_append = nil;
  MSK_remove                    : TMSK_remove = nil;
  MSK_appendcone                : TMSK_appendcone = nil;
  MSK_removecone                : TMSK_removecone = nil;
  MSK_appendvars                : TMSK_appendvars = nil;
  MSK_appendcons                : TMSK_appendcons = nil;
  MSK_bktostr                   : TMSK_bktostr = nil;
  MSK_callbackcodetostr         : TMSK_callbackcodetostr = nil;
  MSK_chgbound                  : TMSK_chgbound = nil;
  MSK_conetypetostr             : TMSK_conetypetostr = nil;
  MSK_deletetask                : TMSK_deletetask = nil;
  (* not translated: MSK_exceptiontask *)
  (* not translated: MSK_echotask *)
  MSK_freetask                  : TMSK_freetask = nil;
  MSK_freedbgtask               : TMSK_freedbgtask = nil;
  MSK_getaij                    : TMSK_getaij = nil;
  MSK_getapiecenumnz            : TMSK_getapiecenumnz = nil;
  MSK_getavecnumnz              : TMSK_getavecnumnz = nil;
  MSK_getavec                   : TMSK_getavec = nil;
  MSK_getaslicenumnz            : TMSK_getaslicenumnz = nil;
  MSK_getaslice                 : TMSK_getaslice = nil;
  MSK_getaslicetrip             : TMSK_getaslicetrip = nil;
  MSK_getbound                  : TMSK_getbound = nil;
  MSK_getboundslice             : TMSK_getboundslice = nil;
  MSK_putboundslice             : TMSK_putboundslice = nil;
  MSK_getc                      : TMSK_getc = nil;
  MSK_getcallbackfunc           : TMSK_getcallbackfunc = nil;
  MSK_getsolutionincallback     : TMSK_getsolutionincallback = nil;
  MSK_getcfix                   : TMSK_getcfix = nil;
  MSK_getcone                   : TMSK_getcone = nil;
  MSK_getconeinfo               : TMSK_getconeinfo = nil;
  MSK_getcslice                 : TMSK_getcslice = nil;
  MSK_getdouinf                 : TMSK_getdouinf = nil;
  MSK_getdouparam               : TMSK_getdouparam = nil;
  MSK_getdualobj                : TMSK_getdualobj = nil;
  MSK_getenv                    : TMSK_getenv = nil;
  MSK_getinfindex               : TMSK_getinfindex = nil;
  MSK_getinfmax                 : TMSK_getinfmax = nil;
  MSK_getinfname                : TMSK_getinfname = nil;
  MSK_getintinf                 : TMSK_getintinf = nil;
  MSK_getintparam               : TMSK_getintparam = nil;
  MSK_getmaxnamelen             : TMSK_getmaxnamelen = nil;
  MSK_getmaxnumanz              : TMSK_getmaxnumanz = nil;
  MSK_getmaxnumcon              : TMSK_getmaxnumcon = nil;
  MSK_getmaxnumvar              : TMSK_getmaxnumvar = nil;
  MSK_getnadouinf               : TMSK_getnadouinf = nil;
  MSK_getnadouparam             : TMSK_getnadouparam = nil;
  MSK_getnaintinf               : TMSK_getnaintinf = nil;
  MSK_getnaintparam             : TMSK_getnaintparam = nil;
  MSK_getname                   : TMSK_getname = nil;
  MSK_getvarname                : TMSK_getvarname = nil;
  MSK_getconname                : TMSK_getconname = nil;
  MSK_getnameindex              : TMSK_getnameindex = nil;
  MSK_getnastrparam             : TMSK_getnastrparam = nil;
  MSK_getnumanz                 : TMSK_getnumanz = nil;
  MSK_getnumcon                 : TMSK_getnumcon = nil;
  MSK_getnumcone                : TMSK_getnumcone = nil;
  MSK_getnumconemem             : TMSK_getnumconemem = nil;
  MSK_getnumintvar              : TMSK_getnumintvar = nil;
  MSK_getnumparam               : TMSK_getnumparam = nil;
  MSK_getnumqconnz              : TMSK_getnumqconnz = nil;
  MSK_getnumqobjnz              : TMSK_getnumqobjnz = nil;
  MSK_getnumvar                 : TMSK_getnumvar = nil;
  MSK_getobjname                : TMSK_getobjname = nil;
  MSK_getparamname              : TMSK_getparamname = nil;
  MSK_getparammax               : TMSK_getparammax = nil;
  MSK_getprimalobj              : TMSK_getprimalobj = nil;
  MSK_getprobtype               : TMSK_getprobtype = nil;
  MSK_getqconk                  : TMSK_getqconk = nil;
  MSK_getqobj                   : TMSK_getqobj = nil;
  MSK_getqobjij                 : TMSK_getqobjij = nil;
  MSK_getsolution               : TMSK_getsolution = nil;
  MSK_getsolutioni              : TMSK_getsolutioni = nil;
  MSK_getsolutioninf            : TMSK_getsolutioninf = nil;
  MSK_getsolutionstatus         : TMSK_getsolutionstatus = nil;
  MSK_getsolutionslice          : TMSK_getsolutionslice = nil;
  MSK_getsolutionstatuskeyslice : TMSK_getsolutionstatuskeyslice = nil;
  MSK_getreducedcosts           : TMSK_getreducedcosts = nil;
  MSK_getstrparam               : TMSK_getstrparam = nil;
  MSK_getstrparamal             : TMSK_getstrparamal = nil;
  MSK_getnastrparamal           : TMSK_getnastrparamal = nil;
  MSK_getsymbcon                : TMSK_getsymbcon = nil;
  MSK_gettaskname               : TMSK_gettaskname = nil;
  MSK_getvartype                : TMSK_getvartype = nil;
  MSK_getvartypelist            : TMSK_getvartypelist = nil;
  MSK_inputdata                 : TMSK_inputdata = nil;
  MSK_isdouparname              : TMSK_isdouparname = nil;
  MSK_isintparname              : TMSK_isintparname = nil;
  MSK_isstrparname              : TMSK_isstrparname = nil;
  MSK_linkfiletotaskstream      : TMSK_linkfiletotaskstream = nil;
  MSK_linkfunctotaskstream      : TMSK_linkfunctotaskstream = nil;
  MSK_unlinkfuncfromtaskstream  : TMSK_unlinkfuncfromtaskstream = nil;
  MSK_clonetask                 : TMSK_clonetask = nil;
  MSK_relaxprimal               : TMSK_relaxprimal = nil;
  MSK_optimizeconcurrent        : TMSK_optimizeconcurrent = nil;
  MSK_checkdata                 : TMSK_checkdata = nil;
  MSK_optimize                  : TMSK_optimize = nil;
  MSK_optimizetrm               : TMSK_optimizetrm = nil;
  MSK_printdata                 : TMSK_printdata = nil;
  MSK_printparam                : TMSK_printparam = nil;
  MSK_probtypetostr             : TMSK_probtypetostr = nil;
  MSK_prostatostr               : TMSK_prostatostr = nil;
  MSK_putresponsefunc           : TMSK_putresponsefunc = nil;
  MSK_commitchanges             : TMSK_commitchanges = nil;
  MSK_putaij                    : TMSK_putaij = nil;
  MSK_putaijlist                : TMSK_putaijlist = nil;
  MSK_putavec                   : TMSK_putavec = nil;
  MSK_putaveclist               : TMSK_putaveclist = nil;
  MSK_putbound                  : TMSK_putbound = nil;
  MSK_putboundlist              : TMSK_putboundlist = nil;
  MSK_putcallbackfunc           : TMSK_putcallbackfunc = nil;
  MSK_putcfix                   : TMSK_putcfix = nil;
  MSK_putcj                     : TMSK_putcj = nil;
  MSK_putobjsense               : TMSK_putobjsense = nil;
  MSK_getobjsense               : TMSK_getobjsense = nil;
  MSK_putclist                  : TMSK_putclist = nil;
  MSK_putcone                   : TMSK_putcone = nil;
  MSK_putdouparam               : TMSK_putdouparam = nil;
  MSK_putintparam               : TMSK_putintparam = nil;
  MSK_putmaxnumcon              : TMSK_putmaxnumcon = nil;
  MSK_putmaxnumcone             : TMSK_putmaxnumcone = nil;
  MSK_getmaxnumcone             : TMSK_getmaxnumcone = nil;
  MSK_putmaxnumvar              : TMSK_putmaxnumvar = nil;
  MSK_putmaxnumanz              : TMSK_putmaxnumanz = nil;
  MSK_putmaxnumqnz              : TMSK_putmaxnumqnz = nil;
  MSK_getmaxnumqnz              : TMSK_getmaxnumqnz = nil;
  MSK_putnadouparam             : TMSK_putnadouparam = nil;
  MSK_putnaintparam             : TMSK_putnaintparam = nil;
  MSK_putname                   : TMSK_putname = nil;
  MSK_putnastrparam             : TMSK_putnastrparam = nil;
  (* not translated: MSK_putnlfunc *)
  (* not translated: MSK_getnlfunc *)
  MSK_putobjname                : TMSK_putobjname = nil;
  MSK_putparam                  : TMSK_putparam = nil;
  MSK_putqcon                   : TMSK_putqcon = nil;
  MSK_putqconk                  : TMSK_putqconk = nil;
  MSK_putqobj                   : TMSK_putqobj = nil;
  MSK_putqobjij                 : TMSK_putqobjij = nil;
  MSK_makesolutionstatusunknown : TMSK_makesolutionstatusunknown = nil;
  MSK_putsolution               : TMSK_putsolution = nil;
  MSK_putsolutioni              : TMSK_putsolutioni = nil;
  MSK_putsolutionyi             : TMSK_putsolutionyi = nil;
  MSK_putstrparam               : TMSK_putstrparam = nil;
  MSK_puttaskname               : TMSK_puttaskname = nil;
  MSK_putvartype                : TMSK_putvartype = nil;
  MSK_putvartypelist            : TMSK_putvartypelist = nil;
  MSK_putvarbranchorder         : TMSK_putvarbranchorder = nil;
  MSK_getvarbranchorder         : TMSK_getvarbranchorder = nil;
  MSK_getvarbranchpri           : TMSK_getvarbranchpri = nil;
  MSK_getvarbranchdir           : TMSK_getvarbranchdir = nil;
  MSK_readdata                  : TMSK_readdata = nil;
  MSK_readparamfile             : TMSK_readparamfile = nil;
  MSK_readsolution              : TMSK_readsolution = nil;
  MSK_readsummary               : TMSK_readsummary = nil;
  MSK_resizetask                : TMSK_resizetask = nil;
  MSK_checkmemtask              : TMSK_checkmemtask = nil;
  MSK_getmemusagetask           : TMSK_getmemusagetask = nil;
  MSK_setdefaults               : TMSK_setdefaults = nil;
  MSK_sktostr                   : TMSK_sktostr = nil;
  MSK_solstatostr               : TMSK_solstatostr = nil;
  MSK_solutiondef               : TMSK_solutiondef = nil;
  MSK_deletesolution            : TMSK_deletesolution = nil;
  MSK_undefsolution             : TMSK_undefsolution = nil;
  MSK_startstat                 : TMSK_startstat = nil;
  MSK_stopstat                  : TMSK_stopstat = nil;
  MSK_appendstat                : TMSK_appendstat = nil;
  MSK_solutionsummary           : TMSK_solutionsummary = nil;
  MSK_strduptask                : TMSK_strduptask = nil;
  MSK_strdupdbgtask             : TMSK_strdupdbgtask = nil;
  MSK_strtoconetype             : TMSK_strtoconetype = nil;
  MSK_strtosk                   : TMSK_strtosk = nil;
  MSK_whichparam                : TMSK_whichparam = nil;
  MSK_writedata                 : TMSK_writedata = nil;
  MSK_readbranchpriorities      : TMSK_readbranchpriorities = nil;
  MSK_writebranchpriorities     : TMSK_writebranchpriorities = nil;
  MSK_writeparamfile            : TMSK_writeparamfile = nil;
  MSK_getinfeasiblesubproblem   : TMSK_getinfeasiblesubproblem = nil;
  MSK_writesolution             : TMSK_writesolution = nil;
  MSK_primalsensitivity         : TMSK_primalsensitivity = nil;
  MSK_sensitivityreport         : TMSK_sensitivityreport = nil;
  MSK_dualsensitivity           : TMSK_dualsensitivity = nil;
  MSK_checkconvexity            : TMSK_checkconvexity = nil;
  MSK_getlasterror              : TMSK_getlasterror = nil;
  MSK_isinfinity                : TMSK_isinfinity = nil;
  MSK_getbuildinfo              : TMSK_getbuildinfo = nil;
  MSK_getresponseclass          : TMSK_getresponseclass = nil;
  MSK_deleteenv                 : TMSK_deleteenv = nil;
  (* not translated: MSK_echoenv *)
  MSK_echointro                 : TMSK_echointro = nil;
  MSK_freeenv                   : TMSK_freeenv = nil;
  MSK_freedbgenv                : TMSK_freedbgenv = nil;
  MSK_getcodedisc               : TMSK_getcodedisc = nil;
  MSK_getsymbcondim             : TMSK_getsymbcondim = nil;
  MSK_getversion                : TMSK_getversion = nil;
  MSK_checkversion              : TMSK_checkversion = nil;
  MSK_iparvaltosymnam           : TMSK_iparvaltosymnam = nil;
  MSK_linkfiletoenvstream       : TMSK_linkfiletoenvstream = nil;
  MSK_linkfunctoenvstream       : TMSK_linkfunctoenvstream = nil;
  MSK_unlinkfuncfromenvstream   : TMSK_unlinkfuncfromenvstream = nil;
  MSK_makeenv                   : TMSK_makeenv = nil;
  MSK_initenv                   : TMSK_initenv = nil;
  MSK_getglbdllname             : TMSK_getglbdllname = nil;
  MSK_putdllpath                : TMSK_putdllpath = nil;
  MSK_putlicensedefaults        : TMSK_putlicensedefaults = nil;
  MSK_putkeepdlls               : TMSK_putkeepdlls = nil;
  MSK_putcpudefaults            : TMSK_putcpudefaults = nil;
  MSK_maketask                  : TMSK_maketask = nil;
  MSK_makeemptytask             : TMSK_makeemptytask = nil;
  MSK_putctrlcfunc              : TMSK_putctrlcfunc = nil;
  MSK_putexitfunc               : TMSK_putexitfunc = nil;
  MSK_replacefileext            : TMSK_replacefileext = nil;
  (* not translated: MSK_utf8towchar *)
  (* not translated: MSK_wchartoutf8 *)
  MSK_checkmemenv               : TMSK_checkmemenv = nil;
  MSK_strdupenv                 : TMSK_strdupenv = nil;
  MSK_strdupdbgenv              : TMSK_strdupdbgenv = nil;
  MSK_symnamtovalue             : TMSK_symnamtovalue = nil;


function LoadMosekDll   : boolean;
function UnLoadMosekDll : boolean;
var
  hMosekDll : THandle = 0;


implementation
uses
  Windows;

function LoadMosekDll: boolean;
begin
  Result := hMosekDll <> 0;
  if not Result then
  begin
    hMosekDll:=LoadLibrary(MosekDllFile);
    if hMosekDll <> 0 then
    begin
      MSK_initbasissolve            := GetProcAddress( hMosekDll, 'MSK_initbasissolve' );
      MSK_solvewithbasis            := GetProcAddress( hMosekDll, 'MSK_solvewithbasis' );
      MSK_append                    := GetProcAddress( hMosekDll, 'MSK_append' );
      MSK_remove                    := GetProcAddress( hMosekDll, 'MSK_remove' );
      MSK_appendcone                := GetProcAddress( hMosekDll, 'MSK_appendcone' );
      MSK_removecone                := GetProcAddress( hMosekDll, 'MSK_removecone' );
      MSK_appendvars                := GetProcAddress( hMosekDll, 'MSK_appendvars' );
      MSK_appendcons                := GetProcAddress( hMosekDll, 'MSK_appendcons' );
      MSK_bktostr                   := GetProcAddress( hMosekDll, 'MSK_bktostr' );
      MSK_callbackcodetostr         := GetProcAddress( hMosekDll, 'MSK_callbackcodetostr' );
      MSK_chgbound                  := GetProcAddress( hMosekDll, 'MSK_chgbound' );
      MSK_conetypetostr             := GetProcAddress( hMosekDll, 'MSK_conetypetostr' );
      MSK_deletetask                := GetProcAddress( hMosekDll, 'MSK_deletetask' );
      MSK_freetask                  := GetProcAddress( hMosekDll, 'MSK_freetask' );
      MSK_freedbgtask               := GetProcAddress( hMosekDll, 'MSK_freedbgtask' );
      MSK_getaij                    := GetProcAddress( hMosekDll, 'MSK_getaij' );
      MSK_getapiecenumnz            := GetProcAddress( hMosekDll, 'MSK_getapiecenumnz' );
      MSK_getavecnumnz              := GetProcAddress( hMosekDll, 'MSK_getavecnumnz' );
      MSK_getavec                   := GetProcAddress( hMosekDll, 'MSK_getavec' );
      MSK_getaslicenumnz            := GetProcAddress( hMosekDll, 'MSK_getaslicenumnz' );
      MSK_getaslice                 := GetProcAddress( hMosekDll, 'MSK_getaslice' );
      MSK_getaslicetrip             := GetProcAddress( hMosekDll, 'MSK_getaslicetrip' );
      MSK_getbound                  := GetProcAddress( hMosekDll, 'MSK_getbound' );
      MSK_getboundslice             := GetProcAddress( hMosekDll, 'MSK_getboundslice' );
      MSK_putboundslice             := GetProcAddress( hMosekDll, 'MSK_putboundslice' );
      MSK_getc                      := GetProcAddress( hMosekDll, 'MSK_getc' );
      MSK_getcallbackfunc           := GetProcAddress( hMosekDll, 'MSK_getcallbackfunc' );
      MSK_getsolutionincallback     := GetProcAddress( hMosekDll, 'MSK_getsolutionincallback' );
      MSK_getcfix                   := GetProcAddress( hMosekDll, 'MSK_getcfix' );
      MSK_getcone                   := GetProcAddress( hMosekDll, 'MSK_getcone' );
      MSK_getconeinfo               := GetProcAddress( hMosekDll, 'MSK_getconeinfo' );
      MSK_getcslice                 := GetProcAddress( hMosekDll, 'MSK_getcslice' );
      MSK_getdouinf                 := GetProcAddress( hMosekDll, 'MSK_getdouinf' );
      MSK_getdouparam               := GetProcAddress( hMosekDll, 'MSK_getdouparam' );
      MSK_getdualobj                := GetProcAddress( hMosekDll, 'MSK_getdualobj' );
      MSK_getenv                    := GetProcAddress( hMosekDll, 'MSK_getenv' );
      MSK_getinfindex               := GetProcAddress( hMosekDll, 'MSK_getinfindex' );
      MSK_getinfmax                 := GetProcAddress( hMosekDll, 'MSK_getinfmax' );
      MSK_getinfname                := GetProcAddress( hMosekDll, 'MSK_getinfname' );
      MSK_getintinf                 := GetProcAddress( hMosekDll, 'MSK_getintinf' );
      MSK_getintparam               := GetProcAddress( hMosekDll, 'MSK_getintparam' );
      MSK_getmaxnamelen             := GetProcAddress( hMosekDll, 'MSK_getmaxnamelen' );
      MSK_getmaxnumanz              := GetProcAddress( hMosekDll, 'MSK_getmaxnumanz' );
      MSK_getmaxnumcon              := GetProcAddress( hMosekDll, 'MSK_getmaxnumcon' );
      MSK_getmaxnumvar              := GetProcAddress( hMosekDll, 'MSK_getmaxnumvar' );
      MSK_getnadouinf               := GetProcAddress( hMosekDll, 'MSK_getnadouinf' );
      MSK_getnadouparam             := GetProcAddress( hMosekDll, 'MSK_getnadouparam' );
      MSK_getnaintinf               := GetProcAddress( hMosekDll, 'MSK_getnaintinf' );
      MSK_getnaintparam             := GetProcAddress( hMosekDll, 'MSK_getnaintparam' );
      MSK_getname                   := GetProcAddress( hMosekDll, 'MSK_getname' );
      MSK_getvarname                := GetProcAddress( hMosekDll, 'MSK_getvarname' );
      MSK_getconname                := GetProcAddress( hMosekDll, 'MSK_getconname' );
      MSK_getnameindex              := GetProcAddress( hMosekDll, 'MSK_getnameindex' );
      MSK_getnastrparam             := GetProcAddress( hMosekDll, 'MSK_getnastrparam' );
      MSK_getnumanz                 := GetProcAddress( hMosekDll, 'MSK_getnumanz' );
      MSK_getnumcon                 := GetProcAddress( hMosekDll, 'MSK_getnumcon' );
      MSK_getnumcone                := GetProcAddress( hMosekDll, 'MSK_getnumcone' );
      MSK_getnumconemem             := GetProcAddress( hMosekDll, 'MSK_getnumconemem' );
      MSK_getnumintvar              := GetProcAddress( hMosekDll, 'MSK_getnumintvar' );
      MSK_getnumparam               := GetProcAddress( hMosekDll, 'MSK_getnumparam' );
      MSK_getnumqconnz              := GetProcAddress( hMosekDll, 'MSK_getnumqconnz' );
      MSK_getnumqobjnz              := GetProcAddress( hMosekDll, 'MSK_getnumqobjnz' );
      MSK_getnumvar                 := GetProcAddress( hMosekDll, 'MSK_getnumvar' );
      MSK_getobjname                := GetProcAddress( hMosekDll, 'MSK_getobjname' );
      MSK_getparamname              := GetProcAddress( hMosekDll, 'MSK_getparamname' );
      MSK_getparammax               := GetProcAddress( hMosekDll, 'MSK_getparammax' );
      MSK_getprimalobj              := GetProcAddress( hMosekDll, 'MSK_getprimalobj' );
      MSK_getprobtype               := GetProcAddress( hMosekDll, 'MSK_getprobtype' );
      MSK_getqconk                  := GetProcAddress( hMosekDll, 'MSK_getqconk' );
      MSK_getqobj                   := GetProcAddress( hMosekDll, 'MSK_getqobj' );
      MSK_getqobjij                 := GetProcAddress( hMosekDll, 'MSK_getqobjij' );
      MSK_getsolution               := GetProcAddress( hMosekDll, 'MSK_getsolution' );
      MSK_getsolutioni              := GetProcAddress( hMosekDll, 'MSK_getsolutioni' );
      MSK_getsolutioninf            := GetProcAddress( hMosekDll, 'MSK_getsolutioninf' );
      MSK_getsolutionstatus         := GetProcAddress( hMosekDll, 'MSK_getsolutionstatus' );
      MSK_getsolutionslice          := GetProcAddress( hMosekDll, 'MSK_getsolutionslice' );
      MSK_getsolutionstatuskeyslice := GetProcAddress( hMosekDll, 'MSK_getsolutionstatuskeyslice' );
      MSK_getreducedcosts           := GetProcAddress( hMosekDll, 'MSK_getreducedcosts' );
      MSK_getstrparam               := GetProcAddress( hMosekDll, 'MSK_getstrparam' );
      MSK_getstrparamal             := GetProcAddress( hMosekDll, 'MSK_getstrparamal' );
      MSK_getnastrparamal           := GetProcAddress( hMosekDll, 'MSK_getnastrparamal' );
      MSK_getsymbcon                := GetProcAddress( hMosekDll, 'MSK_getsymbcon' );
      MSK_gettaskname               := GetProcAddress( hMosekDll, 'MSK_gettaskname' );
      MSK_getvartype                := GetProcAddress( hMosekDll, 'MSK_getvartype' );
      MSK_getvartypelist            := GetProcAddress( hMosekDll, 'MSK_getvartypelist' );
      MSK_inputdata                 := GetProcAddress( hMosekDll, 'MSK_inputdata' );
      MSK_isdouparname              := GetProcAddress( hMosekDll, 'MSK_isdouparname' );
      MSK_isintparname              := GetProcAddress( hMosekDll, 'MSK_isintparname' );
      MSK_isstrparname              := GetProcAddress( hMosekDll, 'MSK_isstrparname' );
      MSK_linkfiletotaskstream      := GetProcAddress( hMosekDll, 'MSK_linkfiletotaskstream' );
      MSK_linkfunctotaskstream      := GetProcAddress( hMosekDll, 'MSK_linkfunctotaskstream' );
      MSK_unlinkfuncfromtaskstream  := GetProcAddress( hMosekDll, 'MSK_unlinkfuncfromtaskstream' );
      MSK_clonetask                 := GetProcAddress( hMosekDll, 'MSK_clonetask' );
      MSK_relaxprimal               := GetProcAddress( hMosekDll, 'MSK_relaxprimal' );
      MSK_optimizeconcurrent        := GetProcAddress( hMosekDll, 'MSK_optimizeconcurrent' );
      MSK_checkdata                 := GetProcAddress( hMosekDll, 'MSK_checkdata' );
      MSK_optimize                  := GetProcAddress( hMosekDll, 'MSK_optimize' );
      MSK_optimizetrm               := GetProcAddress( hMosekDll, 'MSK_optimizetrm' );
      MSK_printdata                 := GetProcAddress( hMosekDll, 'MSK_printdata' );
      MSK_printparam                := GetProcAddress( hMosekDll, 'MSK_printparam' );
      MSK_probtypetostr             := GetProcAddress( hMosekDll, 'MSK_probtypetostr' );
      MSK_prostatostr               := GetProcAddress( hMosekDll, 'MSK_prostatostr' );
      MSK_putresponsefunc           := GetProcAddress( hMosekDll, 'MSK_putresponsefunc' );
      MSK_commitchanges             := GetProcAddress( hMosekDll, 'MSK_commitchanges' );
      MSK_putaij                    := GetProcAddress( hMosekDll, 'MSK_putaij' );
      MSK_putaijlist                := GetProcAddress( hMosekDll, 'MSK_putaijlist' );
      MSK_putavec                   := GetProcAddress( hMosekDll, 'MSK_putavec' );
      MSK_putaveclist               := GetProcAddress( hMosekDll, 'MSK_putaveclist' );
      MSK_putbound                  := GetProcAddress( hMosekDll, 'MSK_putbound' );
      MSK_putboundlist              := GetProcAddress( hMosekDll, 'MSK_putboundlist' );
      MSK_putcallbackfunc           := GetProcAddress( hMosekDll, 'MSK_putcallbackfunc' );
      MSK_putcfix                   := GetProcAddress( hMosekDll, 'MSK_putcfix' );
      MSK_putcj                     := GetProcAddress( hMosekDll, 'MSK_putcj' );
      MSK_putobjsense               := GetProcAddress( hMosekDll, 'MSK_putobjsense' );
      MSK_getobjsense               := GetProcAddress( hMosekDll, 'MSK_getobjsense' );
      MSK_putclist                  := GetProcAddress( hMosekDll, 'MSK_putclist' );
      MSK_putcone                   := GetProcAddress( hMosekDll, 'MSK_putcone' );
      MSK_putdouparam               := GetProcAddress( hMosekDll, 'MSK_putdouparam' );
      MSK_putintparam               := GetProcAddress( hMosekDll, 'MSK_putintparam' );
      MSK_putmaxnumcon              := GetProcAddress( hMosekDll, 'MSK_putmaxnumcon' );
      MSK_putmaxnumcone             := GetProcAddress( hMosekDll, 'MSK_putmaxnumcone' );
      MSK_getmaxnumcone             := GetProcAddress( hMosekDll, 'MSK_getmaxnumcone' );
      MSK_putmaxnumvar              := GetProcAddress( hMosekDll, 'MSK_putmaxnumvar' );
      MSK_putmaxnumanz              := GetProcAddress( hMosekDll, 'MSK_putmaxnumanz' );
      MSK_putmaxnumqnz              := GetProcAddress( hMosekDll, 'MSK_putmaxnumqnz' );
      MSK_getmaxnumqnz              := GetProcAddress( hMosekDll, 'MSK_getmaxnumqnz' );
      MSK_putnadouparam             := GetProcAddress( hMosekDll, 'MSK_putnadouparam' );
      MSK_putnaintparam             := GetProcAddress( hMosekDll, 'MSK_putnaintparam' );
      MSK_putname                   := GetProcAddress( hMosekDll, 'MSK_putname' );
      MSK_putnastrparam             := GetProcAddress( hMosekDll, 'MSK_putnastrparam' );
      MSK_putobjname                := GetProcAddress( hMosekDll, 'MSK_putobjname' );
      MSK_putparam                  := GetProcAddress( hMosekDll, 'MSK_putparam' );
      MSK_putqcon                   := GetProcAddress( hMosekDll, 'MSK_putqcon' );
      MSK_putqconk                  := GetProcAddress( hMosekDll, 'MSK_putqconk' );
      MSK_putqobj                   := GetProcAddress( hMosekDll, 'MSK_putqobj' );
      MSK_putqobjij                 := GetProcAddress( hMosekDll, 'MSK_putqobjij' );
      MSK_makesolutionstatusunknown := GetProcAddress( hMosekDll, 'MSK_makesolutionstatusunknown' );
      MSK_putsolution               := GetProcAddress( hMosekDll, 'MSK_putsolution' );
      MSK_putsolutioni              := GetProcAddress( hMosekDll, 'MSK_putsolutioni' );
      MSK_putsolutionyi             := GetProcAddress( hMosekDll, 'MSK_putsolutionyi' );
      MSK_putstrparam               := GetProcAddress( hMosekDll, 'MSK_putstrparam' );
      MSK_puttaskname               := GetProcAddress( hMosekDll, 'MSK_puttaskname' );
      MSK_putvartype                := GetProcAddress( hMosekDll, 'MSK_putvartype' );
      MSK_putvartypelist            := GetProcAddress( hMosekDll, 'MSK_putvartypelist' );
      MSK_putvarbranchorder         := GetProcAddress( hMosekDll, 'MSK_putvarbranchorder' );
      MSK_getvarbranchorder         := GetProcAddress( hMosekDll, 'MSK_getvarbranchorder' );
      MSK_getvarbranchpri           := GetProcAddress( hMosekDll, 'MSK_getvarbranchpri' );
      MSK_getvarbranchdir           := GetProcAddress( hMosekDll, 'MSK_getvarbranchdir' );
      MSK_readdata                  := GetProcAddress( hMosekDll, 'MSK_readdata' );
      MSK_readparamfile             := GetProcAddress( hMosekDll, 'MSK_readparamfile' );
      MSK_readsolution              := GetProcAddress( hMosekDll, 'MSK_readsolution' );
      MSK_readsummary               := GetProcAddress( hMosekDll, 'MSK_readsummary' );
      MSK_resizetask                := GetProcAddress( hMosekDll, 'MSK_resizetask' );
      MSK_checkmemtask              := GetProcAddress( hMosekDll, 'MSK_checkmemtask' );
      MSK_getmemusagetask           := GetProcAddress( hMosekDll, 'MSK_getmemusagetask' );
      MSK_setdefaults               := GetProcAddress( hMosekDll, 'MSK_setdefaults' );
      MSK_sktostr                   := GetProcAddress( hMosekDll, 'MSK_sktostr' );
      MSK_solstatostr               := GetProcAddress( hMosekDll, 'MSK_solstatostr' );
      MSK_solutiondef               := GetProcAddress( hMosekDll, 'MSK_solutiondef' );
      MSK_deletesolution            := GetProcAddress( hMosekDll, 'MSK_deletesolution' );
      MSK_undefsolution             := GetProcAddress( hMosekDll, 'MSK_undefsolution' );
      MSK_startstat                 := GetProcAddress( hMosekDll, 'MSK_startstat' );
      MSK_stopstat                  := GetProcAddress( hMosekDll, 'MSK_stopstat' );
      MSK_appendstat                := GetProcAddress( hMosekDll, 'MSK_appendstat' );
      MSK_solutionsummary           := GetProcAddress( hMosekDll, 'MSK_solutionsummary' );
      MSK_strduptask                := GetProcAddress( hMosekDll, 'MSK_strduptask' );
      MSK_strdupdbgtask             := GetProcAddress( hMosekDll, 'MSK_strdupdbgtask' );
      MSK_strtoconetype             := GetProcAddress( hMosekDll, 'MSK_strtoconetype' );
      MSK_strtosk                   := GetProcAddress( hMosekDll, 'MSK_strtosk' );
      MSK_whichparam                := GetProcAddress( hMosekDll, 'MSK_whichparam' );
      MSK_writedata                 := GetProcAddress( hMosekDll, 'MSK_writedata' );
      MSK_readbranchpriorities      := GetProcAddress( hMosekDll, 'MSK_readbranchpriorities' );
      MSK_writebranchpriorities     := GetProcAddress( hMosekDll, 'MSK_writebranchpriorities' );
      MSK_writeparamfile            := GetProcAddress( hMosekDll, 'MSK_writeparamfile' );
      MSK_getinfeasiblesubproblem   := GetProcAddress( hMosekDll, 'MSK_getinfeasiblesubproblem' );
      MSK_writesolution             := GetProcAddress( hMosekDll, 'MSK_writesolution' );
      MSK_primalsensitivity         := GetProcAddress( hMosekDll, 'MSK_primalsensitivity' );
      MSK_sensitivityreport         := GetProcAddress( hMosekDll, 'MSK_sensitivityreport' );
      MSK_dualsensitivity           := GetProcAddress( hMosekDll, 'MSK_dualsensitivity' );
      MSK_checkconvexity            := GetProcAddress( hMosekDll, 'MSK_checkconvexity' );
      MSK_getlasterror              := GetProcAddress( hMosekDll, 'MSK_getlasterror' );
      MSK_isinfinity                := GetProcAddress( hMosekDll, 'MSK_isinfinity' );
      MSK_getbuildinfo              := GetProcAddress( hMosekDll, 'MSK_getbuildinfo' );
      MSK_getresponseclass          := GetProcAddress( hMosekDll, 'MSK_getresponseclass' );
      MSK_deleteenv                 := GetProcAddress( hMosekDll, 'MSK_deleteenv' );
      MSK_echointro                 := GetProcAddress( hMosekDll, 'MSK_echointro' );
      MSK_freeenv                   := GetProcAddress( hMosekDll, 'MSK_freeenv' );
      MSK_freedbgenv                := GetProcAddress( hMosekDll, 'MSK_freedbgenv' );
      MSK_getcodedisc               := GetProcAddress( hMosekDll, 'MSK_getcodedisc' );
      MSK_getsymbcondim             := GetProcAddress( hMosekDll, 'MSK_getsymbcondim' );
      MSK_getversion                := GetProcAddress( hMosekDll, 'MSK_getversion' );
      MSK_checkversion              := GetProcAddress( hMosekDll, 'MSK_checkversion' );
      MSK_iparvaltosymnam           := GetProcAddress( hMosekDll, 'MSK_iparvaltosymnam' );
      MSK_linkfiletoenvstream       := GetProcAddress( hMosekDll, 'MSK_linkfiletoenvstream' );
      MSK_linkfunctoenvstream       := GetProcAddress( hMosekDll, 'MSK_linkfunctoenvstream' );
      MSK_unlinkfuncfromenvstream   := GetProcAddress( hMosekDll, 'MSK_unlinkfuncfromenvstream' );
      MSK_makeenv                   := GetProcAddress( hMosekDll, 'MSK_makeenv' );
      MSK_initenv                   := GetProcAddress( hMosekDll, 'MSK_initenv' );
      MSK_getglbdllname             := GetProcAddress( hMosekDll, 'MSK_getglbdllname' );
      MSK_putdllpath                := GetProcAddress( hMosekDll, 'MSK_putdllpath' );
      MSK_putlicensedefaults        := GetProcAddress( hMosekDll, 'MSK_putlicensedefaults' );
      MSK_putkeepdlls               := GetProcAddress( hMosekDll, 'MSK_putkeepdlls' );
      MSK_putcpudefaults            := GetProcAddress( hMosekDll, 'MSK_putcpudefaults' );
      MSK_maketask                  := GetProcAddress( hMosekDll, 'MSK_maketask' );
      MSK_makeemptytask             := GetProcAddress( hMosekDll, 'MSK_makeemptytask' );
      MSK_putctrlcfunc              := GetProcAddress( hMosekDll, 'MSK_putctrlcfunc' );
      MSK_putexitfunc               := GetProcAddress( hMosekDll, 'MSK_putexitfunc' );
      MSK_replacefileext            := GetProcAddress( hMosekDll, 'MSK_replacefileext' );
      MSK_checkmemenv               := GetProcAddress( hMosekDll, 'MSK_checkmemenv' );
      MSK_strdupenv                 := GetProcAddress( hMosekDll, 'MSK_strdupenv' );
      MSK_strdupdbgenv              := GetProcAddress( hMosekDll, 'MSK_strdupdbgenv' );
      MSK_symnamtovalue             := GetProcAddress( hMosekDll, 'MSK_symnamtovalue' );
      hMosekDll := 0;
    end;
  end;
end;

function UnLoadMosekDll: boolean;
begin
  Result := true;
  if hMosekDll <> 0 then
  begin
    Result := FreeLibrary(hMosekDll);
      MSK_initbasissolve            := nil;
      MSK_solvewithbasis            := nil;
      MSK_append                    := nil;
      MSK_remove                    := nil;
      MSK_appendcone                := nil;
      MSK_removecone                := nil;
      MSK_appendvars                := nil;
      MSK_appendcons                := nil;
      MSK_bktostr                   := nil;
      MSK_callbackcodetostr         := nil;
      MSK_chgbound                  := nil;
      MSK_conetypetostr             := nil;
      MSK_deletetask                := nil;
      MSK_freetask                  := nil;
      MSK_freedbgtask               := nil;
      MSK_getaij                    := nil;
      MSK_getapiecenumnz            := nil;
      MSK_getavecnumnz              := nil;
      MSK_getavec                   := nil;
      MSK_getaslicenumnz            := nil;
      MSK_getaslice                 := nil;
      MSK_getaslicetrip             := nil;
      MSK_getbound                  := nil;
      MSK_getboundslice             := nil;
      MSK_putboundslice             := nil;
      MSK_getc                      := nil;
      MSK_getcallbackfunc           := nil;
      MSK_getsolutionincallback     := nil;
      MSK_getcfix                   := nil;
      MSK_getcone                   := nil;
      MSK_getconeinfo               := nil;
      MSK_getcslice                 := nil;
      MSK_getdouinf                 := nil;
      MSK_getdouparam               := nil;
      MSK_getdualobj                := nil;
      MSK_getenv                    := nil;
      MSK_getinfindex               := nil;
      MSK_getinfmax                 := nil;
      MSK_getinfname                := nil;
      MSK_getintinf                 := nil;
      MSK_getintparam               := nil;
      MSK_getmaxnamelen             := nil;
      MSK_getmaxnumanz              := nil;
      MSK_getmaxnumcon              := nil;
      MSK_getmaxnumvar              := nil;
      MSK_getnadouinf               := nil;
      MSK_getnadouparam             := nil;
      MSK_getnaintinf               := nil;
      MSK_getnaintparam             := nil;
      MSK_getname                   := nil;
      MSK_getvarname                := nil;
      MSK_getconname                := nil;
      MSK_getnameindex              := nil;
      MSK_getnastrparam             := nil;
      MSK_getnumanz                 := nil;
      MSK_getnumcon                 := nil;
      MSK_getnumcone                := nil;
      MSK_getnumconemem             := nil;
      MSK_getnumintvar              := nil;
      MSK_getnumparam               := nil;
      MSK_getnumqconnz              := nil;
      MSK_getnumqobjnz              := nil;
      MSK_getnumvar                 := nil;
      MSK_getobjname                := nil;
      MSK_getparamname              := nil;
      MSK_getparammax               := nil;
      MSK_getprimalobj              := nil;
      MSK_getprobtype               := nil;
      MSK_getqconk                  := nil;
      MSK_getqobj                   := nil;
      MSK_getqobjij                 := nil;
      MSK_getsolution               := nil;
      MSK_getsolutioni              := nil;
      MSK_getsolutioninf            := nil;
      MSK_getsolutionstatus         := nil;
      MSK_getsolutionslice          := nil;
      MSK_getsolutionstatuskeyslice := nil;
      MSK_getreducedcosts           := nil;
      MSK_getstrparam               := nil;
      MSK_getstrparamal             := nil;
      MSK_getnastrparamal           := nil;
      MSK_getsymbcon                := nil;
      MSK_gettaskname               := nil;
      MSK_getvartype                := nil;
      MSK_getvartypelist            := nil;
      MSK_inputdata                 := nil;
      MSK_isdouparname              := nil;
      MSK_isintparname              := nil;
      MSK_isstrparname              := nil;
      MSK_linkfiletotaskstream      := nil;
      MSK_linkfunctotaskstream      := nil;
      MSK_unlinkfuncfromtaskstream  := nil;
      MSK_clonetask                 := nil;
      MSK_relaxprimal               := nil;
      MSK_optimizeconcurrent        := nil;
      MSK_checkdata                 := nil;
      MSK_optimize                  := nil;
      MSK_optimizetrm               := nil;
      MSK_printdata                 := nil;
      MSK_printparam                := nil;
      MSK_probtypetostr             := nil;
      MSK_prostatostr               := nil;
      MSK_putresponsefunc           := nil;
      MSK_commitchanges             := nil;
      MSK_putaij                    := nil;
      MSK_putaijlist                := nil;
      MSK_putavec                   := nil;
      MSK_putaveclist               := nil;
      MSK_putbound                  := nil;
      MSK_putboundlist              := nil;
      MSK_putcallbackfunc           := nil;
      MSK_putcfix                   := nil;
      MSK_putcj                     := nil;
      MSK_putobjsense               := nil;
      MSK_getobjsense               := nil;
      MSK_putclist                  := nil;
      MSK_putcone                   := nil;
      MSK_putdouparam               := nil;
      MSK_putintparam               := nil;
      MSK_putmaxnumcon              := nil;
      MSK_putmaxnumcone             := nil;
      MSK_getmaxnumcone             := nil;
      MSK_putmaxnumvar              := nil;
      MSK_putmaxnumanz              := nil;
      MSK_putmaxnumqnz              := nil;
      MSK_getmaxnumqnz              := nil;
      MSK_putnadouparam             := nil;
      MSK_putnaintparam             := nil;
      MSK_putname                   := nil;
      MSK_putnastrparam             := nil;
      MSK_putobjname                := nil;
      MSK_putparam                  := nil;
      MSK_putqcon                   := nil;
      MSK_putqconk                  := nil;
      MSK_putqobj                   := nil;
      MSK_putqobjij                 := nil;
      MSK_makesolutionstatusunknown := nil;
      MSK_putsolution               := nil;
      MSK_putsolutioni              := nil;
      MSK_putsolutionyi             := nil;
      MSK_putstrparam               := nil;
      MSK_puttaskname               := nil;
      MSK_putvartype                := nil;
      MSK_putvartypelist            := nil;
      MSK_putvarbranchorder         := nil;
      MSK_getvarbranchorder         := nil;
      MSK_getvarbranchpri           := nil;
      MSK_getvarbranchdir           := nil;
      MSK_readdata                  := nil;
      MSK_readparamfile             := nil;
      MSK_readsolution              := nil;
      MSK_readsummary               := nil;
      MSK_resizetask                := nil;
      MSK_checkmemtask              := nil;
      MSK_getmemusagetask           := nil;
      MSK_setdefaults               := nil;
      MSK_sktostr                   := nil;
      MSK_solstatostr               := nil;
      MSK_solutiondef               := nil;
      MSK_deletesolution            := nil;
      MSK_undefsolution             := nil;
      MSK_startstat                 := nil;
      MSK_stopstat                  := nil;
      MSK_appendstat                := nil;
      MSK_solutionsummary           := nil;
      MSK_strduptask                := nil;
      MSK_strdupdbgtask             := nil;
      MSK_strtoconetype             := nil;
      MSK_strtosk                   := nil;
      MSK_whichparam                := nil;
      MSK_writedata                 := nil;
      MSK_readbranchpriorities      := nil;
      MSK_writebranchpriorities     := nil;
      MSK_writeparamfile            := nil;
      MSK_getinfeasiblesubproblem   := nil;
      MSK_writesolution             := nil;
      MSK_primalsensitivity         := nil;
      MSK_sensitivityreport         := nil;
      MSK_dualsensitivity           := nil;
      MSK_checkconvexity            := nil;
      MSK_getlasterror              := nil;
      MSK_isinfinity                := nil;
      MSK_getbuildinfo              := nil;
      MSK_getresponseclass          := nil;
      MSK_deleteenv                 := nil;
      MSK_echointro                 := nil;
      MSK_freeenv                   := nil;
      MSK_freedbgenv                := nil;
      MSK_getcodedisc               := nil;
      MSK_getsymbcondim             := nil;
      MSK_getversion                := nil;
      MSK_checkversion              := nil;
      MSK_iparvaltosymnam           := nil;
      MSK_linkfiletoenvstream       := nil;
      MSK_linkfunctoenvstream       := nil;
      MSK_unlinkfuncfromenvstream   := nil;
      MSK_makeenv                   := nil;
      MSK_initenv                   := nil;
      MSK_getglbdllname             := nil;
      MSK_putdllpath                := nil;
      MSK_putlicensedefaults        := nil;
      MSK_putkeepdlls               := nil;
      MSK_putcpudefaults            := nil;
      MSK_maketask                  := nil;
      MSK_makeemptytask             := nil;
      MSK_putctrlcfunc              := nil;
      MSK_putexitfunc               := nil;
      MSK_replacefileext            := nil;
      MSK_checkmemenv               := nil;
      MSK_strdupenv                 := nil;
      MSK_strdupdbgenv              := nil;
      MSK_symnamtovalue             := nil;
  end;
end;

end.
