# Register a qgsim simulation backend

This is an extension API intended for backend packages.

## Usage

``` r
qgsim_register_backend(backend, overwrite = FALSE)
```

## Arguments

- backend:

  A `qgsim_backend` object.

- overwrite:

  Whether to replace an existing backend with the same name.

## Value

Invisibly returns the backend name.
