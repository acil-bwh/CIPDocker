FROM ubuntu:16.04

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
        cmake


RUN git clone -b develop https://github.com/acil-bwh/ChestImagingPlatform.git
RUN	mkdir ChestImagingPlatform-build
WORKDIR /ChestImagingPlatform-build
RUN	cmake ../ChestImagingPlatform/ 
RUN	make

RUN mkdir /host
WORKDIR /host

ENV CIP_BIN="/ChestImagingPlatform-build"
ENV CIP_SRC="/ChestImagingPlatform"
ENV PATH="${CIP_BIN}/CIP-build/bin:${CIP_BIN}/CIPPython-install/bin:${CIP_BIN}/CIPPython-install/Scripts:${CIP_BIN}/Boost-install/lib:${CIP_BIN}/ITKv4-build/bin:${CIP_BIN}/LibXml2-install/bin:${CIP_BIN}/teem-build/bin:${CIP_BIN}/VTKv8-build/bin:${CIP_BIN}/zlib-build:$PATH"
ENV PYTHONPATH="${CIP_BIN}/CIP-build:$PYTHONPATH"

CMD sh
