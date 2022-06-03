# Build Stage
FROM --platform=linux/amd64 ubuntu:22.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git g++ make mesa-common-dev libglu1-mesa-dev libxi-dev

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
WORKDIR /
ADD https://api.github.com/repos/capuanob/trimesh2/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/trimesh2.git
WORKDIR /trimesh2

## Build
RUN make -j$(nproc)

## Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd ./bin.Linux64/mesh_check | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage

FROM --platform=linux/amd64 ubuntu:22.04
COPY --from=builder /trimesh2/bin.Linux64/mesh_check /mesh_check
COPY --from=builder /deps /usr/lib

CMD /mesh_check @@ /dev/stdout
