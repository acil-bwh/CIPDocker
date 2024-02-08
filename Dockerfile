FROM ubuntu:18.04

ENV PATH="/root/miniconda2/bin:${PATH}"
ARG PATH="/root/miniconda2/bin:${PATH}"

RUN apt-get update && \
 	apt-get upgrade -y && \ 
    apt-get install -y \
    	build-essential \
    	freeglut3 \
    	freeglut3-dev \
    	wget \
    	subversion \
    	libxml2-dev \
        git \
        nano \
        cmake && \
        rm -rf /var/lib/apt/lists/*

COPY conda_explicit.txt .
COPY pip_req.txt .
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh  \
    && mkdir /root/.conda \
    && bash Miniconda2-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda2-latest-Linux-x86_64.sh
RUN conda install --file conda_explicit.txt
RUN pip install -r pip_req.txt


RUN git clone -b develop https://github.com/acil-bwh/ChestImagingPlatform.git
WORKDIR /ChestImagingPlatform
RUN git checkout b0a36ed
RUN	mkdir /ChestImagingPlatform-build
WORKDIR /ChestImagingPlatform-build
RUN	cmake -D CIP_USE_GIT_PROTOCOL=OFF -D CIP_PYTHON_INSTALL:BOOL=OFF -D ITK_VERSION_MAJOR:STRING=4 -D USE_BOOST:BOOL=OFF ../ChestImagingPlatform 

RUN	make -j4


COPY chest_conventions_static.py /ChestImagingPlatform/cip_python/common/chest_conventions_static.py

WORKDIR /ChestImagingPlatform
RUN git checkout develop


RUN mkdir /host
WORKDIR /host

ENV CIP_SRC="/ChestImagingPlatform"
ENV CIP_BIN="/ChestImagingPlatform-build"
ENV CIP="/ChestImagingPlatform-build/CIP-build/bin"
ENV CIP_PATH="/ChestImagingPlatform-build/CIP-build/bin"
ENV ITKTOOLS_PATH="/ChestImagingPlatform-build/ITKv4-build/bin"
ENV TEEM="/ChestImagingPlatform-build/teem-build/bin"
ENV TEEM_PATH="/ChestImagingPlatform-build/teem-build/bin"
ENV TMP_DIR="/tmp"

ENV PATH="${CIP}:${TEEM}:${CIP_SRC}:${CIP_BIN}/CIPPython-install/bin:${CIP_BIN}/CIPPython-install/Scripts:${CIP_BIN}/Boost-install/lib:${CIP_BIN}/ITKv4-build/bin:${CIP_BIN}/LibXml2-install/bin:${CIP_BIN}/teem-build/bin:${CIP_BIN}/VTKv8-build/bin:${CIP_BIN}/zlib-build:$PATH"
ENV PYTHONPATH="${CIP_SRC}:$PYTHONPATH"

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4
ENV OMP_NUM_THREADS=4
ENV OPENBLAS_NUM_THREADS=4
ENV MKL_DEBUG_CPU_TYPE=5
ENV MKL_NUM_THREADS=4


CMD sh
