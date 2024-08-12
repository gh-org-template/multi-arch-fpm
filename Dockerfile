ARG ARCHITECTURE=x86_64
ARG DOCKER_REGISTRY=ghcr.io
ARG DOCKER_IMAGE_NAME

# List out all image permutations to trick dependabot
FROM --platform=linux/amd64 ruby:3.2.5-bookworm AS x86_64
FROM --platform=linux/arm64 ruby:3.2.5-bookworm AS aarch64

# Run the build script
FROM $ARCHITECTURE AS build

COPY . /src
RUN /src/build.sh && /src/test.sh

# Copy the build result to scratch so we can export the result
FROM scratch AS package

COPY --from=build /tmp/build /
