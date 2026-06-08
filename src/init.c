#include <R.h>
#include <R_ext/Rdynload.h>
#include <R_ext/RS.h>
#include <R_ext/Visibility.h>
#include <Rinternals.h>

extern SEXP qgsim_gene_drop_cpp(
  SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP
);

extern void F77_NAME(qgsim_gene_drop_fortran)(
  int *, int *, int *, int *, int *, int *, int *, double *, int *, int *,
  double *, int *, int *, int *
);

static const R_CallMethodDef CallEntries[] = {
  {"qgsim_gene_drop_cpp", (DL_FUNC) &qgsim_gene_drop_cpp, 8},
  {NULL, NULL, 0}
};

static const R_FortranMethodDef FortranEntries[] = {
  {"qgsim_gene_drop_fortran", (DL_FUNC) &F77_NAME(qgsim_gene_drop_fortran), 14},
  {NULL, NULL, 0}
};

void attribute_visible R_init_qgsim(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, FortranEntries, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
