script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
example_dir <- if (length(script_arg)) {
  dirname(normalizePath(sub("^--file=", "", script_arg[[1L]])))
} else {
  normalizePath(getwd())
}

source_file <- file.path(example_dir, "qgsim_fortran_example.f90")
old_wd <- setwd(example_dir)
on.exit(setwd(old_wd), add = TRUE)

status <- system2(
  file.path(R.home("bin"), "R"),
  c("CMD", "SHLIB", basename(source_file))
)

if (status != 0L) {
  stop("Fortran shared-library build failed.", call. = FALSE)
}

message("Built ", file.path(example_dir, paste0("qgsim_fortran_example", .Platform$dynlib.ext)))
