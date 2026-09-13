# Workshop package list. To add a package: append it here, rebuild, re-tag.
pkgs <- c(
  # Core flow cytometry
  "flowCore", "flowWorkspace", "openCyto", "ggcyto", "CytoML",
  # Quality control
  "flowAI", "PeacoQC",
  # High-dimensional analysis
  "CATALYST", "FlowSOM", "uwot",
  # General
  "tidyverse", "patchwork", "rmarkdown", "knitr"
)

if (sys.nframe() == 0L) {
  BiocManager::install(pkgs, update = FALSE, ask = FALSE,
                       Ncpus = parallel::detectCores())

  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    message("FAILED to install: ", paste(missing, collapse = ", "))
    quit(status = 1)
  }
  message("All ", length(pkgs), " workshop packages installed.")
}
