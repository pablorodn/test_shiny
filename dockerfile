FROM rstudio/plumber
MAiNTAINER pablorodriguezcv@gmail.com

RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev

RUN apt update -y --allow-releaseinfo-change
RUN apt upgrade -y
RUN apt install -y libmysqlclient-dev
RUN R -e 'install.packages(c("plumber","safer","plyr","DBI","RMySQL"))'

COPY / /plumber_api/

EXPOSE 8000

CMD ["/plumber_api/api.R"]