.empty_population <- function() {
  data.frame(
    replicate = integer(),
    generation = integer(),
    individual_id = character(),
    parent1_id = character(),
    parent2_id = character(),
    breeding_value = numeric(),
    stringsAsFactors = FALSE
  )
}

.r_reference_translate <- function(plan, workdir) {
  qgsim_validate(plan)
  plan
}

.r_reference_execute <- function(input, workdir) {
  plan <- input
  scheme <- plan$scheme

  simulation <- .qgsim_with_seed(plan$simulation$seed, {
    n <- scheme$population_size
    current <- data.frame(
      replicate = rep.int(1L, n),
      generation = rep.int(0L, n),
      individual_id = sprintf("g0_i%04d", seq_len(n)),
      parent1_id = rep.int(NA_character_, n),
      parent2_id = rep.int(NA_character_, n),
      breeding_value = rnorm(n),
      stringsAsFactors = FALSE
    )

    populations <- vector("list", scheme$generations + 1L)
    metrics <- vector("list", scheme$generations + 1L)
    populations[[1L]] <- current
    metrics[[1L]] <- data.frame(
      replicate = 1L,
      generation = 0L,
      metric = "mean_breeding_value",
      value = mean(current$breeding_value),
      stringsAsFactors = FALSE
    )

    for (generation in seq_len(scheme$generations)) {
      selected <- sample(
        current$individual_id,
        size = scheme$selected_parents,
        replace = FALSE
      )
      n_matings <- ceiling(n / scheme$offspring_per_mating)
      parent1 <- sample(selected, n_matings, replace = TRUE)
      parent2 <- sample(selected, n_matings, replace = TRUE)

      parent1 <- rep(parent1, each = scheme$offspring_per_mating)[seq_len(n)]
      parent2 <- rep(parent2, each = scheme$offspring_per_mating)[seq_len(n)]
      values <- setNames(current$breeding_value, current$individual_id)
      offspring_values <- (values[parent1] + values[parent2]) / 2 + rnorm(n, sd = sqrt(0.5))

      current <- data.frame(
        replicate = rep.int(1L, n),
        generation = rep.int(as.integer(generation), n),
        individual_id = sprintf("g%d_i%04d", generation, seq_len(n)),
        parent1_id = unname(parent1),
        parent2_id = unname(parent2),
        breeding_value = unname(offspring_values),
        stringsAsFactors = FALSE
      )
      populations[[generation + 1L]] <- current
      metrics[[generation + 1L]] <- data.frame(
        replicate = 1L,
        generation = as.integer(generation),
        metric = "mean_breeding_value",
        value = mean(current$breeding_value),
        stringsAsFactors = FALSE
      )
    }

    list(
      populations = do.call(rbind, populations),
      metrics = do.call(rbind, metrics)
    )
  })

  structure(
    list(
      status = "success",
      populations = simulation$populations,
      metrics = simulation$metrics,
      logs = "Pure-R reference backend completed successfully."
    ),
    class = "qgsim_backend_run"
  )
}

.r_reference_collect <- function(run, plan, workdir) {
  populations <- if (isTRUE(plan$outputs$populations)) {
    run$populations
  } else {
    .empty_population()
  }
  metrics <- run$metrics[run$metrics$metric %in% plan$outputs$metrics, , drop = FALSE]

  .new_qgsim_result(
    status = run$status,
    backend = list(name = "r_reference", version = "0.0.1"),
    plan = plan,
    metrics = metrics,
    populations = populations,
    logs = run$logs,
    provenance = list(
      qgsim_version = "0.0.1",
      seed = plan$simulation$seed
    )
  )
}

.new_r_reference_backend <- function() {
  .new_qgsim_backend(
    name = "r_reference",
    version = "0.0.1",
    capabilities = c("random_selection", "random_mating", "mean_breeding_value"),
    available = function() TRUE,
    translate = .r_reference_translate,
    execute = .r_reference_execute,
    collect = .r_reference_collect
  )
}
