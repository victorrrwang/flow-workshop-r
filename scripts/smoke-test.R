# Verifies the workshop environment. Run inside the container:
#   Rscript /opt/workshop/smoke-test.R
# Exits non-zero on any failure.

fail <- function(...) {
  message("SMOKE TEST FAILED: ", ...)
  quit(status = 1)
}

# 1. Every package from the install list loads
source("/opt/workshop/install.R")  # defines `pkgs` without installing
for (p in c(pkgs, names(github_pkgs))) {
  ok <- suppressPackageStartupMessages(require(p, character.only = TRUE, quietly = TRUE))
  if (!ok) fail("package '", p, "' does not load")
}
message("OK: ", length(pkgs) + length(github_pkgs), " packages load")

# 1b. Packages we rely on but never name in install.R, because they arrive as
# dependencies of CATALYST. That is a reasonable belief and a bad thing to discover is
# wrong at 10:30 on the morning, so check it explicitly.
implicit <- c("SingleCellExperiment", "ConsensusClusterPlus", "scater", "igraph")
for (p in implicit) {
  ok <- suppressPackageStartupMessages(require(p, character.only = TRUE, quietly = TRUE))
  if (!ok) fail("implicit dependency '", p, "' does not load")
}
message("OK: ", length(implicit), " implicit dependencies load")

# 1c. igraph::compare() provides the adjusted Rand index used to compare clusterings in
# module 04, so no extra package is needed for it. Prove that here.
ari <- igraph::compare(c(1, 1, 2, 2), c(1, 1, 2, 2), method = "adjusted.rand")
if (!isTRUE(all.equal(ari, 1))) fail("igraph::compare adjusted.rand did not return 1")
message("OK: igraph::compare(method = \"adjusted.rand\") works")

# 2. FCS pipeline: read -> compensate -> transform -> plot
data_dir <- "/home/rstudio/data"
fcs <- list.files(data_dir, pattern = "\\.fcs$", ignore.case = TRUE, full.names = TRUE)
if (length(fcs) == 0) {
  message("SKIP: no .fcs file in ", data_dir, " (FCS pipeline and notebook not tested)")
} else {
  res <- tryCatch({
    ff <- read.FCS(fcs[1], transformation = FALSE, truncate_max_range = FALSE)
    spill <- spillover(ff)$SPILL
    if (is.null(spill)) stop("no $SPILL matrix in ", basename(fcs[1]))
    ff <- compensate(ff, spill)
    fl <- colnames(spill)
    ff <- transform(ff, estimateLogicle(ff, channels = fl))
    png_path <- file.path(tempdir(), "smoke.png")
    p <- ggcyto::ggcyto(ff, ggplot2::aes(x = !!rlang::sym(fl[1]), y = `SSC-A`)) +
      ggplot2::geom_hex(bins = 128)
    ggplot2::ggsave(png_path, p, width = 4, height = 4)
    stopifnot(file.size(png_path) > 0)
    TRUE
  }, error = function(e) conditionMessage(e))
  if (!isTRUE(res)) fail("FCS pipeline: ", res)
  message("OK: read/compensate/transform/plot ", basename(fcs[1]))

  # 3. Every workshop notebook knits.
  # Deliberately not a hard-coded filename: as modules 02-05 are added they are gated by
  # this test automatically, and a notebook that cannot knit with the shipped data is a
  # failure worth catching before anyone pulls the image.
  rmds <- list.files("/home/rstudio/workshop", pattern = "\\.Rmd$", full.names = TRUE)
  if (length(rmds) == 0) {
    message("SKIP: no .Rmd found in /home/rstudio/workshop")
  } else {
    for (rmd in sort(rmds)) {
      out <- tryCatch(
        rmarkdown::render(rmd, output_dir = tempdir(), quiet = TRUE,
                          intermediates_dir = tempdir(), envir = new.env()),
        error = function(e) fail("notebook ", basename(rmd), ": ", conditionMessage(e))
      )
      message("OK: knit ", basename(rmd))
    }
  }
}

message("SMOKE TEST PASSED")
