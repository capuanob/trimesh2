# Build Stage
FROM --platform=linux/amd64 ubuntu:22.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y g++ make mesa-common-dev libglu1-mesa-dev libxi-dev

ADD . /trimesh2
WORKDIR /trimesh2

## Build
RUN make -j$(nproc)

## Package Stage

FROM --platform=linux/amd64 ubuntu:22.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libgomp1
COPY --from=builder /trimesh2/bin.Linux64/mesh_check /mesh_check
