IMAGE_NAME= golang-wasm
IMAGE_PREFIX =
IMAGE_TAG ?= latest

.PHONY: wasm-build
wasm-build:
	CGO_ENABLED=0 GOOS=js GOARCH=wasm go build -o main.wasm wasm/main.go

.PHONY: build
build:
	CGO_ENABLED=0 go build -o bin/golang-wasm cmd/main.go

.PHONY: prepare
prepare:
	cp "$(shell go env GOROOT)/misc/wasm/wasm_exec.js" ./
	cp "$(shell go env GOROOT)/misc/wasm/wasm_exec.html" ./index.html
	sed -i 's/test.wasm/main.wasm/' index.html

.PHONY: image-build
image-build:
	docker build -t ${IMAGE_PREFIX}${IMAGE_NAME}:${IMAGE_TAG} .

.PHONY: serve
serve:
	docker run -p 8080:8080 --rm ${IMAGE_PREFIX}${IMAGE_NAME}:${IMAGE_TAG}
