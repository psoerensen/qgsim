.new_qgsim_result <- function(status,
                              backend,
                              plan,
                              metrics,
                              populations,
                              files = data.frame(type = character(), path = character()),
                              logs = character(),
                              provenance = list()) {
  result <- structure(
    list(
      schema = list(name = "qgsim_result", version = "0.0.1"),
      status = status,
      backend = backend,
      plan = plan,
      metrics = metrics,
      populations = populations,
      files = files,
      logs = logs,
      provenance = provenance
    ),
    class = "qgsim_result"
  )
  .validate_qgsim_result(result)
  result
}

.validate_qgsim_result <- function(result) {
  if (!inherits(result, "qgsim_result") || !is.list(result)) {
    .qgsim_stop("Backend collection must return a qgsim_result.")
  }
  .check_exact_names(
    result,
    c(
      "schema", "status", "backend", "plan", "metrics", "populations",
      "files", "logs", "provenance"
    ),
    "qgsim_result"
  )
  if (!identical(result$schema, list(name = "qgsim_result", version = "0.0.1"))) {
    .qgsim_stop("Unsupported qgsim_result schema.")
  }
  if (!result$status %in% c("success", "failed", "partial")) {
    .qgsim_stop("qgsim_result$status is invalid.")
  }
  if (!is.list(result$backend) ||
      !identical(names(result$backend), c("name", "version"))) {
    .qgsim_stop("qgsim_result$backend must contain name and version.")
  }
  qgsim_validate(result$plan)

  metric_fields <- c("replicate", "generation", "metric", "value")
  population_fields <- c(
    "replicate", "generation", "individual_id",
    "parent1_id", "parent2_id", "breeding_value"
  )
  if (!is.data.frame(result$metrics) ||
      !identical(names(result$metrics), metric_fields)) {
    .qgsim_stop("qgsim_result$metrics has an invalid schema.")
  }
  if (!is.data.frame(result$populations) ||
      !identical(names(result$populations), population_fields)) {
    .qgsim_stop("qgsim_result$populations has an invalid schema.")
  }
  if (!is.data.frame(result$files) ||
      !identical(names(result$files), c("type", "path"))) {
    .qgsim_stop("qgsim_result$files has an invalid schema.")
  }
  if (!is.character(result$logs) || !is.list(result$provenance)) {
    .qgsim_stop("qgsim_result logs or provenance has an invalid schema.")
  }
  invisible(TRUE)
}

#' Extract standardized simulation metrics
#'
#' @param result A `qgsim_result`.
#'
#' @return A data frame.
#' @export
qgsim_metrics <- function(result) {
  .validate_qgsim_result(result)
  result$metrics
}

#' Extract standardized simulated populations
#'
#' @param result A `qgsim_result`.
#'
#' @return A data frame.
#' @export
qgsim_populations <- function(result) {
  .validate_qgsim_result(result)
  result$populations
}

#' @export
print.qgsim_result <- function(x, ...) {
  cat("<qgsim_result>\n")
  cat("Status:", x$status, "\n")
  cat("Backend:", x$backend$name, x$backend$version, "\n")
  cat("Generations:", x$plan$scheme$generations, "\n")
  invisible(x)
}
