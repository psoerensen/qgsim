#include <R.h>
#include <Rinternals.h>

namespace {

void apply_gamete(const int *hap1,
                  const int *hap2,
                  int parent_count,
                  int marker_count,
                  int parent,
                  const double *map,
                  int start,
                  int first_crossover,
                  int last_crossover,
                  const double *crossovers,
                  int offspring,
                  int offspring_count,
                  int *output) {
  int haplotype = start;
  int crossover = first_crossover;

  for (int marker = 0; marker < marker_count; ++marker) {
    while (crossover < last_crossover &&
           crossovers[crossover] <= map[marker]) {
      haplotype = 3 - haplotype;
      ++crossover;
    }

    const int parent_offset = parent + parent_count * marker;
    const int output_offset = offspring + offspring_count * marker;
    output[output_offset] =
      haplotype == 1 ? hap1[parent_offset] : hap2[parent_offset];
  }
}

}  // namespace

extern "C" SEXP qgsim_gene_drop_cpp(SEXP hap1_sexp,
                                      SEXP hap2_sexp,
                                      SEXP sire_sexp,
                                      SEXP dam_sexp,
                                      SEXP map_sexp,
                                      SEXP starts_sexp,
                                      SEXP offsets_sexp,
                                      SEXP crossovers_sexp) {
  const int *dimensions = INTEGER(Rf_getAttrib(hap1_sexp, R_DimSymbol));
  const int parent_count = dimensions[0];
  const int marker_count = dimensions[1];
  const int offspring_count = Rf_length(sire_sexp);

  SEXP paternal = PROTECT(Rf_allocMatrix(INTSXP, offspring_count, marker_count));
  SEXP maternal = PROTECT(Rf_allocMatrix(INTSXP, offspring_count, marker_count));
  SEXP genotype = PROTECT(Rf_allocMatrix(INTSXP, offspring_count, marker_count));

  const int *hap1 = INTEGER(hap1_sexp);
  const int *hap2 = INTEGER(hap2_sexp);
  const int *sire = INTEGER(sire_sexp);
  const int *dam = INTEGER(dam_sexp);
  const double *map = REAL(map_sexp);
  const int *starts = INTEGER(starts_sexp);
  const int *offsets = INTEGER(offsets_sexp);
  const double *crossovers = REAL(crossovers_sexp);

  for (int offspring = 0; offspring < offspring_count; ++offspring) {
    apply_gamete(
      hap1, hap2, parent_count, marker_count, sire[offspring] - 1, map,
      starts[offspring], offsets[offspring], offsets[offspring + 1],
      crossovers, offspring, offspring_count, INTEGER(paternal)
    );

    const int maternal_gamete = offspring_count + offspring;
    apply_gamete(
      hap1, hap2, parent_count, marker_count, dam[offspring] - 1, map,
      starts[maternal_gamete], offsets[maternal_gamete],
      offsets[maternal_gamete + 1], crossovers, offspring, offspring_count,
      INTEGER(maternal)
    );
  }

  const R_xlen_t value_count =
    static_cast<R_xlen_t>(offspring_count) * marker_count;
  for (R_xlen_t value = 0; value < value_count; ++value) {
    INTEGER(genotype)[value] = INTEGER(paternal)[value] + INTEGER(maternal)[value];
  }

  SEXP result = PROTECT(Rf_allocVector(VECSXP, 3));
  SET_VECTOR_ELT(result, 0, paternal);
  SET_VECTOR_ELT(result, 1, maternal);
  SET_VECTOR_ELT(result, 2, genotype);

  SEXP names = PROTECT(Rf_allocVector(STRSXP, 3));
  SET_STRING_ELT(names, 0, Rf_mkChar("hap1"));
  SET_STRING_ELT(names, 1, Rf_mkChar("hap2"));
  SET_STRING_ELT(names, 2, Rf_mkChar("genotype"));
  Rf_setAttrib(result, R_NamesSymbol, names);

  UNPROTECT(5);
  return result;
}
