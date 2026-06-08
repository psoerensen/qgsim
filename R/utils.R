.qgsim_stop <- function(...) {
  stop(..., call. = FALSE)
}

.is_positive_integer <- function(x) {
  is.numeric(x) &&
    length(x) == 1L &&
    !is.na(x) &&
    is.finite(x) &&
    x > 0 &&
    x == as.integer(x)
}

.as_positive_integer <- function(x, name) {
  if (!.is_positive_integer(x)) {
    .qgsim_stop("`", name, "` must be a positive integer.")
  }
  as.integer(x)
}

.check_exact_names <- function(x, expected, object_name) {
  actual <- names(x)
  missing <- setdiff(expected, actual)
  unknown <- setdiff(actual, expected)

  if (length(missing)) {
    .qgsim_stop(
      object_name, " is missing required field(s): ",
      paste(missing, collapse = ", "), "."
    )
  }
  if (length(unknown)) {
    .qgsim_stop(
      object_name, " contains unknown field(s): ",
      paste(unknown, collapse = ", "), "."
    )
  }
  invisible(TRUE)
}

.qgsim_with_seed <- function(seed, code) {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) {
    old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  }

  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  set.seed(seed)
  force(code)
}
