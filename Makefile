ARCHITECTURE ?= x86_64
DOCKER_TARGET ?= build
DOCKER_REGISTRY ?= ghcr.io
DOCKER_IMAGE_NAME ?= multi-arch-fpm
DOCKER_IMAGE_TAG ?= $(DOCKER_TARGET)-$(ARCHITECTURE)
DOCKER_NAME ?= $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
DOCKER_RESULT ?= --load

ifeq ($(ARCHITECTURE),aarch64)
	DOCKER_ARCHITECTURE=arm64
else
	DOCKER_ARCHITECTURE=amd64
endif

clean:
	rm -rf package
	docker rmi $(DOCKER_NAME)

docker:
	docker buildx build \
		--build-arg DOCKER_REGISTRY=$(DOCKER_REGISTRY) \
		--build-arg DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) \
		--build-arg DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) \
		--build-arg ARCHITECTURE=$(ARCHITECTURE) \
		--target=$(DOCKER_TARGET) \
		-t $(DOCKER_NAME) \
		$(DOCKER_RESULT) .

build/docker:
	docker inspect --format='{{.Config.Image}}' $(DOCKER_NAME) || \
	$(MAKE) DOCKER_TARGET=build docker

build/package: build/docker
	$(MAKE) DOCKER_TARGET=package DOCKER_RESULT="-o package" docker

.PHONY: init
init:
	pre-commit install

.PHONY: run-pre-commit
run-pre-commit:
	pre-commit run --all-files
