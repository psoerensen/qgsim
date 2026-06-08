.onLoad <- function(libname, pkgname) {
  qgsim_register_backend(.new_r_reference_backend(), overwrite = TRUE)
}
