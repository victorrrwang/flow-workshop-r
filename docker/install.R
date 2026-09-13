# Workshop package list. To add a package: append it here, rebuild, re-tag.
pkgs <- c(
  # Core flow cytometry
  "flowCore", "flowWorkspace", "openCyto", "ggcyto", "CytoML",
  # Quality control
  "flowAI", "PeacoQC",
  # High-dimensional analysis
  "CATALYST", "FlowSOM", "uwot",
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
