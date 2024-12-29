ARG ARCHITECTURE=x86_64
ARG DOCKER_REGISTRY=ghcr.io
ARG DOCKER_IMAGE_NAME
ARG DOCKER_ARCHITECTURE
ARG VERSION=3.4.1
FROM --platform=linux/${ARCHITECTURE} ruby:${VERSION}-bookworm AS build

COPY . /src
RUN /src/build.sh && /src/test.sh

# Copy the build result to scratch so we can export the result
FROM scratch AS package

COPY --from=build /tmp/build /
