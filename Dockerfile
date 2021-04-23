FROM rocker/r-ver:4.0.4

RUN apt-get update; apt-get install -y \
  git-core \
  libgit2-dev \
  libicu-dev \
  libpng-dev \
  libssl-dev \
  libudunits2-dev \
  libxml2-dev \
  make \
  pandoc \
  pandoc-citeproc \
  unixodbc-dev \
  zlib1g-dev \
  curl \
  gnupg2 \
  libcurl3-gnutls \
  libproj-dev \
  openjdk-11-jre \
  r-cran-tcltk2
 
RUN rm -rf /var/lib/apt/lists/*

RUN echo "options( \
  repos = c(CRAN = 'https://cran.rstudio.com/'), \
  download.file.method = 'libcurl')" \
  >> /usr/local/lib/R/etc/Rprofile.site

RUN R -e 'install.packages("remotes")'

RUN R -e "install.packages( \
  c('shiny', 'shinydashboard', 'DT', 'config', 'data.table', 'dplyr', \
    'golem', 'httr', 'jsonlite', 'magrittr', 'openxlsx', 'purrr', 'rvest', \
    'stringr', 'tibble', 'tidyr', 'xml2') \
  )"

RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone

RUN R -e 'remotes::install_local(upgrade="never")'

EXPOSE 80

COPY shiny-server.conf /etc/build_zone/shiny-server.conf

CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');lfshiny::run_app()"
