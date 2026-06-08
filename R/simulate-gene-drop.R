#' Simulate gene dropping through a pedigree
#'
#' Simulates a simple single-chromosome gene-dropping example. The supplied
#' base haplotypes form generation 0. In each subsequent generation, selected
#' parents produce offspring whose paternal and maternal haplotypes are formed
#' by recombination.
#'
#' This function is intended for teaching and small examples. It is not a
#' scientifically complete breeding simulator.
#'
#' @param base_haplotypes A list containing `hap1` and `hap2`, both 0/1
#'   matrices with individuals in rows and markers in columns.
#' @param map Numeric vector of marker positions in Morgans. Positions must be
#'   finite, non-missing, non-decreasing, and span a positive chromosome
#'   length.
#' @param generations Number of generations to simulate after generation 0.
#' @param population_size Number of offspring in each simulated generation.
#' @param selected_parents Total number of parents selected from each previous
#'   generation. At least two parents are required.
#' @param offspring_per_mating Number of offspring generated per mating.
#' @param sample_size Number of individuals sampled from the final generation.
#' @param seed Optional non-negative integer random seed.
#' @param keep Whether returned haplotypes should contain only sampled
#'   individuals (`"sample"`) or all simulated individuals (`"all"`).
#'
#' @return An object of class `qgsim_gene_drop`, containing the pedigree,
#'   retained haplotypes, sampled individuals, map, and simulation parameters.
#' @export
#'
#' @examples
#' base <- list(
#'   hap1 = matrix(c(0, 0, 1, 1, 0, 1, 0, 1), nrow = 4, byrow = TRUE),
#'   hap2 = matrix(c(1, 1, 0, 0, 1, 0, 1, 0), nrow = 4, byrow = TRUE)
#' )
#'
#' result <- simulate_gene_drop(
#'   base_haplotypes = base,
#'   map = c(0, 0.5),
#'   generations = 2,
#'   population_size = 4,
#'   selected_parents = 4,
#'   offspring_per_mating = 2,
#'   sample_size = 2,
#'   seed = 123
#' )
simulate_gene_drop <- function(base_haplotypes,
                               map,
                               generations,
                               population_size,
                               selected_parents,
                               offspring_per_mating,
                               sample_size = population_size,
                               seed = NULL,
                               keep = c("sample", "all")) {
  base_haplotypes <- .validate_base_haplotypes(base_haplotypes)
  map <- .validate_gene_drop_map(map, ncol(base_haplotypes$hap1))
  generations <- .as_integer_at_least(generations, "generations", 1L)
  population_size <- .as_integer_at_least(
    population_size,
    "population_size",
    1L
  )
  selected_parents <- .as_integer_at_least(
    selected_parents,
    "selected_parents",
    2L
  )
  offspring_per_mating <- .as_integer_at_least(
    offspring_per_mating,
    "offspring_per_mating",
    1L
  )
  sample_size <- .as_integer_at_least(sample_size, "sample_size", 1L)
  keep <- match.arg(keep)

  if (selected_parents > population_size) {
    stop("`selected_parents` must not exceed `population_size`.", call. = FALSE)
  }
  if (selected_parents > nrow(base_haplotypes$hap1)) {
    stop(
      "`selected_parents` must not exceed the number of base individuals.",
      call. = FALSE
    )
  }
  if (sample_size > population_size) {
    stop("`sample_size` must not exceed `population_size`.", call. = FALSE)
  }
  if (!is.null(seed)) {
    seed <- .as_integer_at_least(seed, "seed", 0L)
    set.seed(seed)
  }

  n_sires <- ceiling(selected_parents / 2)
  n_dams <- selected_parents - n_sires
  base_size <- nrow(base_haplotypes$hap1)

  pedigree_by_generation <- vector("list", generations + 1L)
  hap1_by_generation <- vector("list", generations + 1L)
  hap2_by_generation <- vector("list", generations + 1L)

  pedigree_by_generation[[1L]] <- data.frame(
    id = sprintf("g0_i%04d", seq_len(base_size)),
    sire = NA_character_,
    dam = NA_character_,
    generation = rep.int(0L, base_size),
    sex = .gene_drop_sexes(base_size, n_sires, n_dams),
    stringsAsFactors = FALSE
  )
  hap1_by_generation[[1L]] <- base_haplotypes$hap1
  hap2_by_generation[[1L]] <- base_haplotypes$hap2

  for (generation in seq_len(generations)) {
    previous_index <- generation
    previous <- pedigree_by_generation[[previous_index]]
    previous_hap1 <- hap1_by_generation[[previous_index]]
    previous_hap2 <- hap2_by_generation[[previous_index]]

    sire_ids <- sample(previous$id[previous$sex == "M"], n_sires)
    dam_ids <- sample(previous$id[previous$sex == "F"], n_dams)
    n_matings <- ceiling(population_size / offspring_per_mating)
    mating_sires <- sample(sire_ids, n_matings, replace = TRUE)
    mating_dams <- sample(dam_ids, n_matings, replace = TRUE)
    offspring_sires <- rep(mating_sires, each = offspring_per_mating)
    offspring_dams <- rep(mating_dams, each = offspring_per_mating)
    retained <- seq_len(population_size)
    offspring_sires <- offspring_sires[retained]
    offspring_dams <- offspring_dams[retained]

    offspring_hap1 <- matrix(
      0L,
      nrow = population_size,
      ncol = length(map)
    )
    offspring_hap2 <- offspring_hap1

    for (individual in retained) {
      sire_row <- match(offspring_sires[individual], previous$id)
      dam_row <- match(offspring_dams[individual], previous$id)
      offspring_hap1[individual, ] <- drop_gamete_r(
        previous_hap1[sire_row, ],
        previous_hap2[sire_row, ],
        map
      )
      offspring_hap2[individual, ] <- drop_gamete_r(
        previous_hap1[dam_row, ],
        previous_hap2[dam_row, ],
        map
      )
    }

    output_index <- generation + 1L
    pedigree_by_generation[[output_index]] <- data.frame(
      id = sprintf("g%d_i%04d", generation, retained),
      sire = offspring_sires,
      dam = offspring_dams,
      generation = rep.int(as.integer(generation), population_size),
      sex = .gene_drop_sexes(population_size, n_sires, n_dams),
      stringsAsFactors = FALSE
    )
    hap1_by_generation[[output_index]] <- offspring_hap1
    hap2_by_generation[[output_index]] <- offspring_hap2
  }

  pedigree <- do.call(rbind, pedigree_by_generation)
  rownames(pedigree) <- NULL
  all_hap1 <- do.call(rbind, hap1_by_generation)
  all_hap2 <- do.call(rbind, hap2_by_generation)

  final_rows <- which(pedigree$generation == generations)
  sampled_rows <- sample(final_rows, sample_size)
  sample_table <- pedigree[sampled_rows, c("id", "generation"), drop = FALSE]
  rownames(sample_table) <- NULL

  if (keep == "sample") {
    retained_haplotypes <- list(
      hap1 = all_hap1[sampled_rows, , drop = FALSE],
      hap2 = all_hap2[sampled_rows, , drop = FALSE]
    )
    sample_table$haplotype_row <- seq_len(sample_size)
  } else {
    retained_haplotypes <- list(hap1 = all_hap1, hap2 = all_hap2)
    sample_table$haplotype_row <- sampled_rows
  }

  structure(
    list(
      pedigree = pedigree,
      haplotypes = retained_haplotypes,
      sample = sample_table,
      map = map,
      parameters = list(
        generations = generations,
        population_size = population_size,
        selected_parents = selected_parents,
        offspring_per_mating = offspring_per_mating,
        sample_size = sample_size,
        seed = seed,
        keep = keep
      )
    ),
    class = "qgsim_gene_drop"
  )
}

#' @export
print.qgsim_gene_drop <- function(x, ...) {
  cat("<qgsim_gene_drop>\n")
  cat("  generations:", x$parameters$generations, "\n")
  cat("  pedigree individuals:", nrow(x$pedigree), "\n")
  cat("  sampled individuals:", nrow(x$sample), "\n")
  cat("  retained haplotypes:", nrow(x$haplotypes$hap1), "\n")
  invisible(x)
}

drop_gamete_r <- function(hap1, hap2, map) {
  chromosome_start <- min(map)
  chromosome_end <- max(map)
  chromosome_length <- chromosome_end - chromosome_start
  n_crossovers <- stats::rpois(1L, chromosome_length)
  crossovers <- sort(stats::runif(
    n_crossovers,
    min = chromosome_start,
    max = chromosome_end
  ))
  starting_haplotype <- sample(c(1L, 2L), 1L)
  switches <- findInterval(map, crossovers)
  use_hap1 <- (switches %% 2L == 0L) == (starting_haplotype == 1L)
  ifelse(use_hap1, hap1, hap2)
}

.gene_drop_sexes <- function(n, n_sires, n_dams) {
  required <- c(rep("M", n_sires), rep("F", n_dams))
  remaining <- sample(c("M", "F"), n - length(required), replace = TRUE)
  sample(c(required, remaining))
}

.validate_base_haplotypes <- function(base_haplotypes) {
  if (!is.list(base_haplotypes) ||
      !all(c("hap1", "hap2") %in% names(base_haplotypes))) {
    stop("`base_haplotypes` must be a list with `hap1` and `hap2`.", call. = FALSE)
  }

  hap1 <- base_haplotypes$hap1
  hap2 <- base_haplotypes$hap2
  if (!is.matrix(hap1) || !is.matrix(hap2) ||
      !is.numeric(hap1) || !is.numeric(hap2)) {
    stop("`hap1` and `hap2` must be numeric or integer matrices.", call. = FALSE)
  }
  if (!identical(dim(hap1), dim(hap2))) {
    stop("`hap1` and `hap2` must have the same dimensions.", call. = FALSE)
  }
  if (nrow(hap1) < 1L || ncol(hap1) < 1L) {
    stop("Haplotype matrices must have at least one row and column.", call. = FALSE)
  }
  if (anyNA(hap1) || anyNA(hap2) ||
      any(!is.finite(hap1)) || any(!is.finite(hap2)) ||
      any(!hap1 %in% c(0, 1)) || any(!hap2 %in% c(0, 1))) {
    stop("Haplotype matrices must contain only 0/1 values.", call. = FALSE)
  }

  list(
    hap1 = matrix(as.integer(hap1), nrow = nrow(hap1)),
    hap2 = matrix(as.integer(hap2), nrow = nrow(hap2))
  )
}

.validate_gene_drop_map <- function(map, marker_count) {
  if (!is.numeric(map) || is.matrix(map) || length(map) != marker_count ||
      anyNA(map) || any(!is.finite(map))) {
    stop(
      "`map` must be a finite numeric vector with one position per marker.",
      call. = FALSE
    )
  }
  if (is.unsorted(map, strictly = FALSE)) {
    stop("`map` must be non-decreasing.", call. = FALSE)
  }
  if (max(map) - min(map) <= 0) {
    stop("The chromosome length defined by `map` must be greater than 0.", call. = FALSE)
  }
  as.numeric(map)
}
