#' Gene drop one generation
#'
#' Simulates Mendelian inheritance with recombination for a complete
#' generation. Each offspring receives one gamete from its sire and one from
#' its dam. Random inheritance events are generated in R, then applied by the
#' selected R, C++, or Fortran marker loop.
#'
#' This is a simple single-chromosome teaching example, not a scientifically
#' complete breeding simulator.
#'
#' @param hap1,hap2 Numeric or integer 0/1 matrices containing the two
#'   parental haplotypes. Rows are parents and columns are markers.
#' @param sire,dam Integer-like vectors giving the parental row indices for
#'   each offspring.
#' @param map Numeric vector of marker positions in Morgans. Positions must be
#'   finite, non-missing, non-decreasing, and span a positive chromosome
#'   length.
#' @param seed `NULL` or a single integer-like random seed.
#' @param engine Implementation used to apply inheritance events.
#' @param return_haplotypes Whether to include transmitted paternal and
#'   maternal haplotypes in the result.
#'
#' @return A list containing the offspring `genotype`, mating design, map, and
#'   selected engine. When `return_haplotypes = TRUE`, the list also contains
#'   transmitted paternal `hap1` and maternal `hap2` matrices.
#' @export
#'
#' @examples
#' hap1 <- matrix(c(0, 0, 1, 1, 0, 1, 0, 1), nrow = 2, byrow = TRUE)
#' hap2 <- 1L - hap1
#'
#' gene_drop_generation(
#'   hap1,
#'   hap2,
#'   sire = c(1, 2),
#'   dam = c(2, 1),
#'   map = c(0, 0.5, 0.8, 1),
#'   seed = 123
#' )
gene_drop_generation <- function(hap1,
                                 hap2,
                                 sire,
                                 dam,
                                 map,
                                 seed = NULL,
                                 engine = c("R", "C++", "Fortran"),
                                 return_haplotypes = TRUE) {
  haplotypes <- .validate_generation_haplotypes(hap1, hap2)
  hap1 <- haplotypes$hap1
  hap2 <- haplotypes$hap2
  sire <- .validate_parent_indices(sire, "sire", nrow(hap1))
  dam <- .validate_parent_indices(dam, "dam", nrow(hap1))

  if (length(sire) != length(dam)) {
    stop("`sire` and `dam` must have the same positive length.", call. = FALSE)
  }

  map <- .validate_gene_drop_map(map, ncol(hap1))
  seed <- .validate_generation_seed(seed)
  engine <- match.arg(engine)

  if (!is.logical(return_haplotypes) ||
      length(return_haplotypes) != 1L ||
      is.na(return_haplotypes)) {
    stop("`return_haplotypes` must be TRUE or FALSE.", call. = FALSE)
  }

  if (!is.null(seed)) {
    set.seed(seed)
  }

  events <- .gene_drop_events(length(sire), map)
  inherited <- switch(
    engine,
    R = .gene_drop_generation_r(hap1, hap2, sire, dam, map, events),
    `C++` = .gene_drop_generation_cpp(hap1, hap2, sire, dam, map, events),
    Fortran = .gene_drop_generation_fortran(
      hap1, hap2, sire, dam, map, events
    )
  )

  result <- list(
    genotype = inherited$genotype,
    sire = sire,
    dam = dam,
    map = map,
    engine = engine
  )

  if (return_haplotypes) {
    result$hap1 <- inherited$hap1
    result$hap2 <- inherited$hap2
  }

  result
}

.validate_generation_haplotypes <- function(hap1, hap2) {
  if (!is.matrix(hap1) || !is.matrix(hap2) ||
      !is.numeric(hap1) || !is.numeric(hap2)) {
    stop("`hap1` and `hap2` must be numeric or integer matrices.", call. = FALSE)
  }
  if (!identical(dim(hap1), dim(hap2))) {
    stop("`hap1` and `hap2` must have identical dimensions.", call. = FALSE)
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

.validate_parent_indices <- function(x, name, parent_count) {
  if (!is.numeric(x) || is.matrix(x) || length(x) < 1L ||
      anyNA(x) || any(!is.finite(x)) || any(x != floor(x)) ||
      any(x < 1) || any(x > parent_count)) {
    stop(
      "`", name, "` must contain valid integer-like parent row indices.",
      call. = FALSE
    )
  }
  as.integer(x)
}

.validate_generation_seed <- function(seed) {
  if (is.null(seed)) {
    return(NULL)
  }
  if (!is.numeric(seed) || length(seed) != 1L || is.na(seed) ||
      !is.finite(seed) || seed != floor(seed) ||
      seed < -.Machine$integer.max || seed > .Machine$integer.max) {
    stop("`seed` must be NULL or a single integer-like value.", call. = FALSE)
  }
  as.integer(seed)
}

.gene_drop_events <- function(offspring_count, map) {
  gamete_count <- 2L * offspring_count
  chromosome_start <- min(map)
  chromosome_end <- max(map)
  chromosome_length <- chromosome_end - chromosome_start
  starts <- sample.int(2L, gamete_count, replace = TRUE)
  crossover_counts <- stats::rpois(gamete_count, chromosome_length)
  crossovers <- lapply(crossover_counts, function(count) {
    sort(stats::runif(count, chromosome_start, chromosome_end))
  })
  flattened_crossovers <- as.numeric(unlist(crossovers, use.names = FALSE))
  if (length(flattened_crossovers) == 0L) {
    flattened_crossovers <- 0
  }

  list(
    starts = as.integer(starts),
    offsets = as.integer(c(0, cumsum(crossover_counts))),
    crossovers = flattened_crossovers
  )
}

.gene_drop_generation_r <- function(hap1, hap2, sire, dam, map, events) {
  offspring_count <- length(sire)
  marker_count <- length(map)
  paternal <- matrix(0L, offspring_count, marker_count)
  maternal <- matrix(0L, offspring_count, marker_count)

  apply_gamete <- function(parent, gamete_index) {
    first <- events$offsets[gamete_index] + 1L
    last <- events$offsets[gamete_index + 1L]
    crossovers <- if (first <= last) events$crossovers[first:last] else numeric()
    switches <- findInterval(map, crossovers)
    use_hap1 <- (switches %% 2L == 0L) == (events$starts[gamete_index] == 1L)
    ifelse(use_hap1, hap1[parent, ], hap2[parent, ])
  }

  for (offspring in seq_len(offspring_count)) {
    paternal[offspring, ] <- apply_gamete(sire[offspring], offspring)
    maternal[offspring, ] <- apply_gamete(
      dam[offspring],
      offspring_count + offspring
    )
  }

  list(hap1 = paternal, hap2 = maternal, genotype = paternal + maternal)
}

.gene_drop_generation_cpp <- function(hap1, hap2, sire, dam, map, events) {
  .Call(
    qgsim_gene_drop_cpp,
    hap1,
    hap2,
    sire,
    dam,
    map,
    events$starts,
    events$offsets,
    events$crossovers
  )
}

.gene_drop_generation_fortran <- function(hap1, hap2, sire, dam, map, events) {
  offspring_count <- length(sire)
  marker_count <- length(map)
  inherited <- .Fortran(
    qgsim_gene_drop_fortran,
    hap1 = hap1,
    hap2 = hap2,
    parent_count = as.integer(nrow(hap1)),
    marker_count = as.integer(marker_count),
    sire = sire,
    dam = dam,
    offspring_count = as.integer(offspring_count),
    map = map,
    starts = events$starts,
    offsets = events$offsets,
    crossovers = events$crossovers,
    paternal = integer(offspring_count * marker_count),
    maternal = integer(offspring_count * marker_count),
    genotype = integer(offspring_count * marker_count)
  )

  list(
    hap1 = matrix(inherited$paternal, offspring_count, marker_count),
    hap2 = matrix(inherited$maternal, offspring_count, marker_count),
    genotype = matrix(inherited$genotype, offspring_count, marker_count)
  )
}
