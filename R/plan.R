#' Compile a breeding-scheme specification
#'
#' @param scheme A `qgsim_scheme` created by [breeding_scheme()].
#' @param seed Integer random seed.
#' @param outputs A `qgsim_outputs` created by [output_spec()].
#'
#' @return A validated object of class `qgsim_plan`.
#' @export
qgsim_compile <- function(scheme,
                          seed = 1L,
                          outputs = output_spec()) {
  if (!inherits(scheme, "qgsim_scheme")) {
    .qgsim_stop("`scheme` must be created by `breeding_scheme()`.")
  }
  if (!inherits(outputs, "qgsim_outputs")) {
    .qgsim_stop("`outputs` must be created by `output_spec()`.")
  }
  if (!is.numeric(seed) || length(seed) != 1L || is.na(seed) ||
      !is.finite(seed) || seed < 0 || seed != as.integer(seed)) {
    .qgsim_stop("`seed` must be a non-negative integer.")
  }

  plan <- structure(
    list(
      schema = list(name = "qgsim_plan", version = "0.0.1"),
      simulation = list(seed = as.integer(seed)),
      scheme = unclass(scheme),
      outputs = unclass(outputs)
    ),
    class = "qgsim_plan"
  )

  qgsim_validate(plan)
  plan
}

#' Validate a compiled qgsim plan
#'
#' @param plan A `qgsim_plan`.
#'
#' @return Invisibly returns `TRUE` when validation succeeds.
#' @export
qgsim_validate <- function(plan) {
  if (!inherits(plan, "qgsim_plan") || !is.list(plan)) {
    .qgsim_stop("`plan` must be a qgsim_plan.")
  }

  .check_exact_names(
    plan,
    c("schema", "simulation", "scheme", "outputs"),
    "qgsim_plan"
  )

  if (!identical(plan$schema, list(name = "qgsim_plan", version = "0.0.1"))) {
    .qgsim_stop("Unsupported qgsim_plan schema.")
  }

  .check_exact_names(plan$simulation, "seed", "qgsim_plan$simulation")
  seed <- plan$simulation$seed
  if (!is.numeric(seed) || length(seed) != 1L || is.na(seed) ||
      !is.finite(seed) || seed < 0 || seed != as.integer(seed)) {
    .qgsim_stop("qgsim_plan$simulation$seed must be a non-negative integer.")
  }

  scheme_fields <- c(
    "generations",
    "population_size",
    "selected_parents",
    "offspring_per_mating"
  )
  .check_exact_names(plan$scheme, scheme_fields, "qgsim_plan$scheme")
  for (field in scheme_fields) {
    if (!.is_positive_integer(plan$scheme[[field]])) {
      .qgsim_stop("qgsim_plan$scheme$", field, " must be a positive integer.")
    }
  }
  if (plan$scheme$selected_parents > plan$scheme$population_size) {
    .qgsim_stop(
      "qgsim_plan$scheme$selected_parents must not exceed population_size."
    )
  }

  .check_exact_names(plan$outputs, c("populations", "metrics"), "qgsim_plan$outputs")
  if (!is.logical(plan$outputs$populations) ||
      length(plan$outputs$populations) != 1L ||
      is.na(plan$outputs$populations)) {
    .qgsim_stop("qgsim_plan$outputs$populations must be TRUE or FALSE.")
  }
  if (!is.character(plan$outputs$metrics) || anyNA(plan$outputs$metrics)) {
    .qgsim_stop("qgsim_plan$outputs$metrics must be a character vector.")
  }
  unsupported <- setdiff(unique(plan$outputs$metrics), .qgsim_supported_metrics)
  if (length(unsupported)) {
    .qgsim_stop(
      "Unsupported output metric(s): ",
      paste(unsupported, collapse = ", "), "."
    )
  }

  invisible(TRUE)
}

#' @export
print.qgsim_plan <- function(x, ...) {
  cat("<qgsim_plan>\n")
  cat("Schema:", x$schema$version, "\n")
  cat("Generations:", x$scheme$generations, "\n")
  cat("Population size:", x$scheme$population_size, "\n")
  cat("Seed:", x$simulation$seed, "\n")
  invisible(x)
}
