FROM nvidia/cuda:12.3.1-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmysqlclient-dev \
    build-essential \
    fakeroot \
    devscripts \
    equivs \
    wget

# Build
VOLUME ["/input", "/output"]
WORKDIR /input
CMD mk-build-deps -t "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" -i debian/control && \
    debuild -b -uc -us && \
    cp ../slurm-smd*.deb /output/
