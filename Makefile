default: build-image

SHELL := /bin/bash

PWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

VCS_REF := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

IMAGE_NAME ?= "k8s-on-gce-toolset"
IMAGE_TAG ?= "alpha"
CONTAINER_NAME ?= $(IMAGE_NAME)

DOCKER_PUBLISH_NAME ?= "shmileee/$(IMAGE_NAME)"
DOCKER_PUBLISH_TAG ?= $(IMAGE_TAG)

.PHONY: build-image
build-image:
	docker build --squash -f Dockerfile -t $(IMAGE_NAME):$(IMAGE_TAG) \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) .

.PHONY: stop-container
stop-container:
	-@docker rm -f $(CONTAINER_NAME) 2>/dev/null || true

.PHONY: clean
clean: stop-container
	-@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true

.PHONY: publish
publish:
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(DOCKER_PUBLISH_NAME):$(DOCKER_PUBLISH_TAG)
	docker push $(DOCKER_PUBLISH_NAME):$(DOCKER_PUBLISH_TAG)

.PHONY: exec
exec: stop-container
	docker run -it \
    -v $(PWD)/src:/root/src \
    -v $$HOME/.ssh:/root/.ssh \
    --name $(CONTAINER_NAME) $(IMAGE_NAME):$(IMAGE_TAG)
