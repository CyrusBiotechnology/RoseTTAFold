ARG CUDA=11.0
FROM nvidia/cuda:${CUDA}-cudnn8-runtime-ubuntu18.04
# FROM directive resets ARGS, so we specify again (the value is retained if
# previously set).
ARG CUDA

ARG ROSETTACOMMONS_CONDA_USERNAME
ARG ROSETTACOMMONS_CONDA_PASSWORD

RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive

RUN apt install -y cmake
RUN apt-get install -y wget libgomp1 unzip git build-essential && rm -rf /var/lib/apt/lists/*
RUN apt-get update

RUN wget -q \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /var/conda\
    && rm -f Miniconda3-latest-Linux-x86_64.sh

ENV PATH /var/conda/bin:$PATH

RUN conda --version

COPY . /RoseTTaFold
WORKDIR /RoseTTaFold

RUN conda config --set remote_max_retries 5
RUN conda config --set remote_backoff_factor 20

RUN conda env create -q -f RoseTTAFold-linux.yml
RUN conda env create -q -f folding-linux.yml

RUN conda config --add channels https://${ROSETTACOMMONS_CONDA_USERNAME}:${ROSETTACOMMONS_CONDA_PASSWORD}@conda.graylab.jhu.edu
#installing pyrosetta into a base image so it gets cached between builds
RUN conda install -n folding pyrosetta=2020.45

RUN chmod +x install_dependencies.sh
RUN ./install_dependencies.sh

WORKDIR /home
RUN git clone --progress --verbose https://github.com/soedinglab/hh-suite.git
RUN mkdir -p hh-suite/build && cd hh-suite/build
WORKDIR /home/hh-suite/build
RUN cmake -DCMAKE_INSTALL_PREFIX=. ..
RUN make -j 4 && make install
ENV PATH $(pwd)/bin:$(pwd)/scripts:$PATH

ENV PATH /RoseTTaFold:$PATH

WORKDIR /RoseTTaFold
