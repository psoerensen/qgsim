.qgsim_backends <- new.env(parent = emptyenv())

.new_qgsim_backend <- function(name,
                               version,
                               capabilities,
                               available,
                               translate,
                               execute,
                               collect) {
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    .qgsim_stop("Backend `name` must be a non-empty character scalar.")
  }
  if (!is.character(version) || length(version) != 1L || !nzchar(version)) {
    .qgsim_stop("Backend `version` must be a non-empty character scalar.")
  }
  if (!is.character(capabilities) || anyNA(capabilities)) {
    .qgsim_stop("Backend `capabilities` must be a character vector.")
  }

  functions <- list(
    available = available,
    translate = translate,
    execute = execute,
    collect = collect
  )
  if (!all(vapply(functions, is.function, logical(1)))) {
    .qgsim_stop("Backend available, translate, execute, and collect fields must be functions.")
  }

  structure(
    c(
      list(
        name = name,
        version = version,
        capabilities = unique(capabilities)
      ),
      functions
    ),
    class = "qgsim_backend"
  )
}

.validate_backend <- function(backend) {
  if (!inherits(backend, "qgsim_backend")) {
    .qgsim_stop("`backend` must be a qgsim_backend.")
  }
  .check_exact_names(
    backend,
    c(
      "name", "version", "capabilities", "available",
      "translate", "execute", "collect"
    ),
    "qgsim_backend"
  )
  invisible(TRUE)
}

#' Register a qgsim simulation backend
#'
#' This is an extension API intended for backend packages.
#'
#' @param backend A `qgsim_backend` object.
#' @param overwrite Whether to replace an existing backend with the same name.
#'
#' @return Invisibly returns the backend name.
#' @export
qgsim_register_backend <- function(backend, overwrite = FALSE) {
  .validate_backend(backend)
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    .qgsim_stop("`overwrite` must be TRUE or FALSE.")
  }

  name <- backend$name
  if (exists(name, envir = .qgsim_backends, inherits = FALSE) && !overwrite) {
    .qgsim_stop("Backend `", name, "` is already registered.")
  }
  assign(name, backend, envir = .qgsim_backends)
  invisible(name)
}

#' List registered qgsim backends
#'
#' @return Character vector of backend names.
#' @export
qgsim_list_backends <- function() {
  sort(ls(envir = .qgsim_backends))
}

#' Inspect a registered qgsim backend
#'
#' @param name Registered backend name.
#'
#' @return Backend metadata without executable functions.
#' @export
qgsim_backend_info <- function(name) {
  backend <- .get_qgsim_backend(name)
  list(
    name = backend$name,
    version = backend$version,
    capabilities = backend$capabilities,
    available = isTRUE(backend$available())
  )
}

.get_qgsim_backend <- function(name) {
  if (!is.character(name) || length(name) != 1L || !nzchar(name)) {
    .qgsim_stop("`backend` must be a registered backend name.")
  }
  if (!exists(name, envir = .qgsim_backends, inherits = FALSE)) {
    .qgsim_stop(
      "Unknown backend `", name, "`. Available backends: ",
      paste(qgsim_list_backends(), collapse = ", "), "."
    )
  }
  get(name, envir = .qgsim_backends, inherits = FALSE)
}

#' @export
print.qgsim_backend <- function(x, ...) {
  cat("<qgsim_backend>", x$name, x$version, "\n")
  cat("Capabilities:", paste(x$capabilities, collapse = ", "), "\n")
  invisible(x)
}
