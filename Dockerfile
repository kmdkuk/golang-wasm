FROM golang:1.21 as builder

WORKDIR /app

COPY go.mod go.mod
RUN go mod download

COPY Makefile Makefile
COPY cmd/ cmd/
COPY wasm/ wasm/

RUN make prepare
RUN make wasm-build
RUN make build

FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /app/bin/golang-wasm .
COPY --from=builder /app/main.wasm .
COPY --from=builder /app/index.html .
COPY --from=builder /app/wasm_exec.js .

EXPOSE 8080
CMD ["/golang-wasm"]
