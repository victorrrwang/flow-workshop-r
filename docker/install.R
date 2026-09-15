# Workshop package list. To add a package: append it here, rebuild, re-tag.
pkgs <- c(
  # Core flow cytometry
  "flowCore", "flowWorkspace", "openCyto", "ggcyto", "CytoML",
  # Quality control
  "flowAI", "PeacoQC",
  # High-dimensional analysis
  "CATALYST", "FlowSOM", "uwot",
  # Clustering methods compared in module 04.
  #   flowPeaks: density-mode clustering. Source dates from 2012 and carries compiled C,
  #              so it is the most likely package here to fail an arm64 build -- which is
  #              exactly why CI builds both architectures before anyone pulls the image.
  #   bluster:   makeSNNGraph, for the Leiden arm. Leiden itself is igraph::cluster_leiden,
  #              and igraph already arrives with FlowSOM. The CRAN `leiden` package is
  #              deliberately NOT used: it calls Python through reticulate, and a Python
  #              runtime is an explicit non-goal for this image.
  "flowPeaks", "bluster",
  # General
  "tidyverse", "patchwork", "rmarkdown", "knitr", "remotes"
)

# GitHub packages: name = "owner/repo[/subdir]@commit". Pin a commit SHA so rebuilds match.
github_pkgs <- c(
  speedyflowplot = "victorrrwang/speedyflowplot/pkg@c3c6544fa6e5894a91b2d22d6513663968db0862"
)

if (sys.nframe() == 0L) {
  BiocManager::install(pkgs, update = FALSE, ask = FALSE,
                       Ncpus = parallel::detectCores())
  for (ref in github_pkgs) {
    remotes::install_github(ref, upgrade = "never", dependencies = TRUE)
  }

  all_pkgs <- c(pkgs, names(github_pkgs))
  missing <- all_pkgs[!vapply(all_pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    message("FAILED to install: ", paste(missing, collapse = ", "))
    quit(status = 1)
  }
  message("All ", length(all_pkgs), " workshop packages installed.")
}
