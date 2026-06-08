.qgsim_supported_metrics <- "mean_breeding_value"

#' Define a minimal breeding scheme
#'
#' @param generations Number of offspring generations to simulate.
#' @param population_size Number of individuals in each generation.
#' @param selected_parents Number of parents randomly selected each generation.
#' @param offspring_per_mating Number of offspring produced by each mating.
#'
#' @return An object of class `qgsim_scheme`.
#' @export
breeding_scheme <- function(generations,
                            population_size,
                            selected_parents,
                            offspring_per_mating) {
  generations <- .as_positive_integer(generations, "generations")
  population_size <- .as_positive_integer(population_size, "population_size")
  selected_parents <- .as_positive_integer(selected_parents, "selected_parents")
  offspring_per_mating <- .as_positive_integer(
    offspring_per_mating,
    "offspring_per_mating"
  )

  if (selected_parents > population_size) {
    .qgsim_stop("`selected_parents` must not exceed `population_size`.")
  }

  structure(
    list(
      generations = generations,
      population_size = population_size,
      selected_parents = selected_parents,
      offspring_per_mating = offspring_per_mating
    ),
    class = "qgsim_scheme"
  )
}

#' Define requested simulation outputs
#'
#' @param populations Whether to return individual-level population records.
#' @param metrics Character vector of requested generation-level metrics.
#'
#' @return An object of class `qgsim_outputs`.
#' @export
output_spec <- function(populations = TRUE,
                        metrics = "mean_breeding_value") {
  if (!is.logical(populations) || length(populations) != 1L || is.na(populations)) {
    .qgsim_stop("`populations` must be TRUE or FALSE.")
  }
  if (!is.character(metrics) || anyNA(metrics) || any(!nzchar(metrics))) {
    .qgsim_stop("`metrics` must be a character vector of supported metric names.")
  }

  unsupported <- setdiff(unique(metrics), .qgsim_supported_metrics)
  if (length(unsupported)) {
    .qgsim_stop(
      "Unsupported output metric(s): ",
      paste(unsupported, collapse = ", "), "."
    )
  }

  structure(
    list(
      populations = populations,
      metrics = unique(metrics)
    ),
    class = "qgsim_outputs"
  )
}

#' @export
print.qgsim_scheme <- function(x, ...) {
  cat("<qgsim_scheme>\n")
  cat("Generations:", x$generations, "\n")
  cat("Population size:", x$population_size, "\n")
  cat("Selected parents:", x$selected_parents, "\n")
  invisible(x)
}
