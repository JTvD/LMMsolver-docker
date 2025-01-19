# r2py docker imge: https://hub.docker.com/u/rpy2
# How to build yourself: https://github.com/rpy2/rpy2-docker?tab=readme-ov-file
FROM  rpy2/base-ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update

#R packages SF depencies, needed for the R package lmmsolver
RUN apt-get install libssl-dev -y
RUN apt-get -y update && apt-get install -y  libudunits2-dev -y libgdal-dev -y libgeos-dev -y libproj-dev -y

# Install R packages
RUN R -e "install.packages('openssl',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('units',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('s2',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('sf',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('LMMsolver',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# the container Comes with basic python and R installation

# Pip update
RUN python3 -m pip install --upgrade pip

#COPY . .
COPY requirements.txt ./
COPY src src



RUN apt-get -y update
# RUN python3 -m pip install -r requirements.txt
RUN python3 -m pip install rpy2 --upgrade
# Set working directory
WORKDIR "/"

# Automatically start script when the docker is loaded
#CMD ["./run.sh"]