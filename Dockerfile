FROM debian:12-slim AS build

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install git build-essential

WORKDIR /
RUN git clone --recursive https://github.com/purplei2p/i2pd-tools

WORKDIR /i2pd-tools

RUN sed -i -e "s/sudo//" -e "s/apt install/apt install -y/" dependencies.sh && \
    sed -i -e "s/sudo//" -e "s/apt-get install/apt-get install -y/" dependencies.sh && \
    bash dependencies.sh 

#RUN git submodule init && git submodule update && \
#    git submodule update --init && \
#    git pull --recurse-submodules && \
RUN  make

RUN mkdir -p /artifact
RUN find . -maxdepth 1 -type f -executable ! -name "*.*" ! -iname '*.sample' -exec cp {} /artifact/ \;
RUN rm -f /artifact/Makefile

FROM debian:12-slim

RUN mkdir -p /artifact
COPY --from=build /artifact /i2pd-tools

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y \
    libboost-chrono1.74.0 \
    libboost-date-time1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-program-options1.74.0 \
    libboost-system1.74.0 \
    libboost-thread1.74.0 \
    libssl3 \
    zlib1g

#Clean up
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /i2pd-tools