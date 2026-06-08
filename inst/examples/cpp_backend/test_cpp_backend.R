script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
example_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1L]])))
} else {
  normalizePath(getwd())
}

library_path <- file.path(example_dir, paste0("qgsim_cpp_example", .Platform$dynlib.ext))
if (!file.exists(library_path)) {
  message("Shared library not found. Run build.R with a working C++ compiler.")
  quit(save = "no", status = 0L)
}
if (!requireNamespace("qgsim", quietly = TRUE)) {
  repo_dir <- normalizePath(file.path(example_dir, "..", "..", ".."), mustWork = FALSE)
  if (file.exists(file.path(repo_dir, "DESCRIPTION")) &&
      requireNamespace("devtools", quietly = TRUE)) {
    devtools::load_all(repo_dir, quiet = TRUE)
  }
}
if (!requireNamespace("qgsim", quietly = TRUE)) {
  stop("Install or load qgsim before running this example.", call. = FALSE)
}

dyn.load(library_path)
on.exit(dyn.unload(library_path), add = TRUE)

cpp_translate <- function(plan, workdir) {
  qgsim::qgsim_validate(plan)
  list(
    generations = plan$scheme$generations,
    population_size = plan$scheme$population_size,
    initial_values = as.numeric(seq_len(plan$scheme$population_size) - 1L)
  )
}

cpp_execute <- function(input, workdir) {
  values <- vector("list", input$generations + 1L)
  values[[1L]] <- input$initial_values
  for (generation in seq_len(input$generations)) {
    values[[generation + 1L]] <- .Call(
      "qgsim_cpp_update",
      values[[generation]],
      as.numeric(generation)
    )
  }
  structure(
    list(status = "success", values = values),
    class = "qgsim_backend_run"
  )
}

cpp_collect <- function(run, plan, workdir) {
  populations <- do.call(rbind, lapply(seq_along(run$values), function(index) {
    generation <- index - 1L
    values <- run$values[[index]]
    data.frame(
      replicate = rep.int(1L, length(values)),
      generation = rep.int(generation, length(values)),
      individual_id = sprintf("g%d_i%04d", generation, seq_along(values)),
      parent1_id = rep.int(NA_character_, length(values)),
      parent2_id = rep.int(NA_character_, length(values)),
      breeding_value = values,
      stringsAsFactors = FALSE
    )
  }))
  metrics <- do.call(rbind, lapply(seq_along(run$values), function(index) {
    data.frame(
      replicate = 1L,
      generation = index - 1L,
      metric = "mean_breeding_value",
      value = mean(run$values[[index]]),
      stringsAsFactors = FALSE
    )
  }))

  qgsim:::.new_qgsim_result(
    status = run$status,
    backend = list(name = "cpp_example", version = "0.0.1"),
    plan = plan,
    metrics = metrics[metrics$metric %in% plan$outputs$metrics, , drop = FALSE],
    populations = if (isTRUE(plan$outputs$populations)) populations else qgsim:::.empty_population(),
    logs = "Toy C++ shared-library backend completed.",
    provenance = list(shared_library = normalizePath(library_path))
  )
}

backend <- qgsim:::.new_qgsim_backend(
  name = "cpp_example",
  version = "0.0.1",
  capabilities = "mean_breeding_value",
  available = function() is.loaded("qgsim_cpp_update"),
  translate = cpp_translate,
  execute = cpp_execute,
  collect = cpp_collect
)
qgsim::qgsim_register_backend(backend, overwrite = TRUE)

plan <- qgsim::qgsim_compile(
  qgsim::breeding_scheme(2L, 5L, 2L, 2L),
  outputs = qgsim::output_spec(populations = TRUE, metrics = "mean_breeding_value")
)
result <- qgsim::qgsim_run(plan, backend = "cpp_example")
print(result)
print(qgsim::qgsim_metrics(result))
