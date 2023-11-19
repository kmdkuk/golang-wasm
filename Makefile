IMAGE_NAME= golang-wasm
IMAGE_PREFIX =
IMAGE_TAG ?= latest

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: wasm-js-build
wasm-js-build:
	CGO_ENABLED=0 GOOS=js GOARCH=wasm go build -o main-js.wasm wasm/main.go

.PHONY: wasm-wasip1-build
wasm-wasip1-build:
	GOOS=wasip1 GOARCH=wasm go build -o main-wasip1.wasm wasm/main.go

.PHONY: wasm-run
wasm-run: wasmtime wasm-wasip1-build
	$(WASMTIME) main-wasip1.wasm

.PHONY: build
build:
	CGO_ENABLED=0 go build -o bin/golang-wasm cmd/main.go

.PHONY: prepare
prepare:
	cp "$(shell go env GOROOT)/misc/wasm/wasm_exec.js" ./
	cp "$(shell go env GOROOT)/misc/wasm/wasm_exec.html" ./index.html
	sed -i 's/test.wasm/main-js.wasm/' index.html

.PHONY: image-build
image-build:
	docker build -t ${IMAGE_PREFIX}${IMAGE_NAME}:${IMAGE_TAG} .

.PHONY: serve
serve:
	docker run -p 8080:8080 --rm ${IMAGE_PREFIX}${IMAGE_NAME}:${IMAGE_TAG}

LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

WASMTIME=$(LOCALBIN)/wasmtime
.PHONY: wasmtime
wasmtime: $(WASMTIME)
$(WASMTIME): $(LOCALBIN)
	test -s $(WASMTIME) || curl -fsL https://github.com/bytecodealliance/wasmtime/releases/download/v14.0.4/wasmtime-v14.0.4-x86_64-linux.tar.xz | tar --strip-components 1  -C $(LOCALBIN) -Jxf -
