#include <R.h>
#include <Rinternals.h>

extern "C" SEXP qgsim_cpp_update(SEXP values, SEXP increment) {
  if (!Rf_isReal(values) || Rf_length(increment) != 1) {
    Rf_error("Expected a numeric vector and a scalar increment.");
  }

  SEXP result = PROTECT(Rf_duplicate(values));
  const double step = Rf_asReal(increment);

  for (R_xlen_t i = 0; i < XLENGTH(result); ++i) {
    REAL(result)[i] += step;
  }

  UNPROTECT(1);
  return result;
}
