FROM alpine:3.15.0 AS drone-ca-certs

RUN apk add --update-cache --no-cache ca-certificates



FROM golang:1.17.8-alpine AS compilation

ARG CGO_ENABLED=0
ARG VERSION
ARG ARCH

RUN apk add --update-cache --no-cache git && \
    git clone https://github.com/harness/drone-cli -b ${VERSION} && \
    cd drone-cli && \
    GOOS=linux GOARCH=${ARCH} go build -ldflags "-X main.version=${VERSION}" -o release/linux/${ARCH}/drone ./drone



FROM scratch

ARG ARCH

COPY --from=drone-ca-certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=compilation /go/drone-cli/release/linux/${ARCH}/drone /bin/

ENTRYPOINT ["/bin/drone"]
