DOCKER_IMAGE := nathanleclaire/tarzan
DOCKER_CONTAINER := tarzan-build
DOCKER_SRC_PATH := /go/src/github.com/nathanleclaire/tarzan

default: dockerbuild

dockerbuild: clean
	docker build -t $(DOCKER_IMAGE) .
	docker run --name $(DOCKER_CONTAINER) $(DOCKER_IMAGE) 
	docker cp $(DOCKER_CONTAINER):$(DOCKER_SRC_PATH)/tarzan .
	docker rm $(DOCKER_CONTAINER)

cleanbinary:
	rm -f tarzan

cleancontainers:
	docker rm $(DOCKER_CONTAINER) $(DOCKER_CONTAINER)-deps 2>/dev/null || true

deps: cleancontainers
	docker run --name $(DOCKER_CONTAINER)-deps \
		-v $(shell pwd):$(DOCKER_SRC_PATH) \
		$(DOCKER_IMAGE) sh -c "go get github.com/tools/godep && pwd && go get ./... && godep save"
	docker rm $(DOCKER_CONTAINER)-deps 2>/dev/null || true

clean: cleanbinary cleancontainers
