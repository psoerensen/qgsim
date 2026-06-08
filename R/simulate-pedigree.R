#' Simulate a multi-generational pedigree
#'
#' Creates a simple pedigree for teaching and small examples. Generation 1
#' contains founders with missing parents. Each later generation is produced
#' from selected males and females in the previous generation.
#'
#' @param generations Number of generations, including the founder generation.
#' @param population_size Number of individuals in each generation.
#' @param selected_parents Number of parents selected from each previous
#'   generation.
#' @param offspring_per_mating Number of offspring generated per mating.
#' @param seed Optional integer random seed for reproducible results.
#'
#' @return A data frame with columns `id`, `sire`, `dam`, `generation`, and
#'   `sex`.
#' @export
#'
#' @examples
#' ped <- simulate_pedigree(
#'   generations = 3,
#'   population_size = 100,
#'   selected_parents = 20,
#'   offspring_per_mating = 5,
#'   seed = 123
#' )
simulate_pedigree <- function(generations,
                              population_size,
                              selected_parents,
                              offspring_per_mating,
                              seed = NULL) {
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

  if (selected_parents > population_size) {
    stop("`selected_parents` must not exceed `population_size`.", call. = FALSE)
  }
  if (!is.null(seed)) {
    seed <- .as_integer_at_least(seed, "seed", 0L)
    set.seed(seed)
  }

  make_sexes <- function(n) {
    sample(rep(c("M", "F"), length.out = n))
  }

  founders <- data.frame(
    id = sprintf("g1_i%04d", seq_len(population_size)),
    sire = NA_character_,
    dam = NA_character_,
    generation = rep.int(1L, population_size),
    sex = make_sexes(population_size),
    stringsAsFactors = FALSE
  )

  pedigree <- vector("list", generations)
  pedigree[[1L]] <- founders

  if (generations == 1L) {
    return(founders)
  }

  n_sires <- ceiling(selected_parents / 2)
  n_dams <- selected_parents - n_sires

  for (generation in 2:generations) {
    previous <- pedigree[[generation - 1L]]
    males <- previous$id[previous$sex == "M"]
    females <- previous$id[previous$sex == "F"]

    if (length(males) < n_sires || length(females) < n_dams) {
      stop(
        "There must be enough selected males and females for reproduction.",
        call. = FALSE
      )
    }

    sires <- sample(males, n_sires)
    dams <- sample(females, n_dams)
    n_matings <- ceiling(population_size / offspring_per_mating)
    mating_sires <- sample(sires, n_matings, replace = TRUE)
    mating_dams <- sample(dams, n_matings, replace = TRUE)

    offspring_sires <- rep(mating_sires, each = offspring_per_mating)
    offspring_dams <- rep(mating_dams, each = offspring_per_mating)
    keep <- seq_len(population_size)

    pedigree[[generation]] <- data.frame(
      id = sprintf("g%d_i%04d", generation, keep),
      sire = offspring_sires[keep],
      dam = offspring_dams[keep],
      generation = rep.int(as.integer(generation), population_size),
      sex = make_sexes(population_size),
      stringsAsFactors = FALSE
    )
  }

  pedigree <- do.call(rbind, pedigree)
  rownames(pedigree) <- NULL
  pedigree
}

.as_integer_at_least <- function(x, name, minimum) {
  if (!is.numeric(x) ||
      length(x) != 1L ||
      is.na(x) ||
      !is.finite(x) ||
      x != as.integer(x) ||
      x < minimum) {
    stop(
      "`", name, "` must be an integer greater than or equal to ", minimum, ".",
      call. = FALSE
    )
  }
  as.integer(x)
}
