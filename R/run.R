#' Run a compiled breeding-scheme simulation
#'
#' @param plan A validated `qgsim_plan`.
#' @param backend Name of a registered backend.
#' @param workdir Optional working directory. A temporary directory is used by
#'   default.
#'
#' @return A standardized `qgsim_result`.
#' @export
qgsim_run <- function(plan,
                      backend = "r_reference",
                      workdir = NULL) {
  qgsim_validate(plan)
  backend_object <- .get_qgsim_backend(backend)
  .validate_backend(backend_object)

  if (!isTRUE(backend_object$available())) {
    .qgsim_stop("Backend `", backend, "` is not available.")
  }

  if (is.null(workdir)) {
    workdir <- tempfile("qgsim_run_")
  }
  dir.create(workdir, recursive = TRUE, showWarnings = FALSE)

  input <- backend_object$translate(plan, workdir)
  run <- backend_object$execute(input, workdir)
  if (!inherits(run, "qgsim_backend_run")) {
    .qgsim_stop("Backend `", backend, "` execute() did not return a qgsim_backend_run.")
  }

  result <- backend_object$collect(run, plan, workdir)
  .validate_qgsim_result(result)
  result
}
