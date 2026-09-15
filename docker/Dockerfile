FROM bioconductor/bioconductor_docker:RELEASE_3_23-r-4.6.1

LABEL org.opencontainers.image.title="flow-workshop-r" \
      org.opencontainers.image.description="RStudio + Bioconductor packages for flow cytometry analysis workshop" \
      org.opencontainers.image.source="https://github.com/victorrrwang/flow-workshop-r"

COPY docker/install.R /opt/workshop/install.R
RUN Rscript /opt/workshop/install.R && rm -rf /tmp/downloaded_packages

COPY scripts/smoke-test.R /opt/workshop/smoke-test.R

# System-wide RStudio defaults: same pane layout, font size and session behaviour for
# everyone. Users can still change anything in Tools > Global Options; their changes go to
# ~/.config/rstudio/ and override these. save_workspace/load_workspace are off on purpose,
# so a broken session never restores itself on restart.
COPY docker/rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

RUN mkdir -p /home/rstudio/data /home/rstudio/workshop \
    && chown -R rstudio:rstudio /home/rstudio
