# GLOBAL VARIABLES
ARG NODE_VERSION=14.19.3
ARG GOLANG_VERSION=1.18
ARG PULUMI_VERSION=3.43.1
ARG MINIO_PROVIDER_VERSION=0.13.2
ARG NATS_PROVIDER_VERSION=0.6.0

# nats-box go builder
FROM golang:${GOLANG_VERSION}-alpine AS builder

WORKDIR $GOPATH/src/github.com/nats-io/

RUN apk add -U --no-cache git binutils
RUN go install github.com/nats-io/nats-top@v0.5.2
RUN go install -ldflags="-X main.version=2.7.1" github.com/nats-io/nsc@2.7.1
RUN go install github.com/nats-io/natscli/nats@v0.0.34
RUN go install github.com/nats-io/stan.go/examples/stan-pub@latest
RUN go install github.com/nats-io/stan.go/examples/stan-sub@latest
RUN go install github.com/nats-io/stan.go/examples/stan-bench@latest

# pulumi node base image
FROM node:${NODE_VERSION}-alpine
# https://stackoverflow.com/questions/53681522/share-variable-in-multi-stage-dockerfile-arg-before-from-not-substituted
ARG PULUMI_VERSION
ARG MINIO_PROVIDER_VERSION
ARG NATS_PROVIDER_VERSION

# pulumi resource
RUN apk add --update make
RUN wget -O pulumi.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v${PULUMI_VERSION}-linux-x64.tar.gz \
    && tar -zxf pulumi.tar.gz \
    && mkdir -p /usr/local/pulumi \
    && cp pulumi/pulumi pulumi/pulumi-language-nodejs pulumi/pulumi-resource-pulumi-nodejs /usr/local/pulumi/ \
    && rm pulumi.tar.gz \
    && rm -rf pulumi/

# minio
RUN mkdir -p /usr/local/pulumi/plugins/resource-minio-v${MINIO_PROVIDER_VERSION} \
    && cd /usr/local/pulumi/plugins/resource-minio-v${MINIO_PROVIDER_VERSION} \
    && wget -O pulumi-resource-minio.tar.gz https://github.com/pulumi/pulumi-minio/releases/download/v${MINIO_PROVIDER_VERSION}/pulumi-resource-minio-v${MINIO_PROVIDER_VERSION}-linux-amd64.tar.gz \
    && tar -zxf pulumi-resource-minio.tar.gz \
    && rm pulumi-resource-minio.tar.gz

# nats-box
ENV NKEYS_PATH /nsc/nkeys
ENV XDG_DATA_HOME /nsc
ENV XDG_CONFIG_HOME /nsc/.config

# copy from nats-box builder to node image
RUN apk add -U --no-cache ca-certificates figlet
COPY --from=builder /go/bin/* /usr/local/bin/
RUN cd /usr/local/bin/ && \
    ln -s nats-box nats-pub && \
    ln -s nats-box nats-sub && \
    ln -s nats-box nats-req && \
    ln -s nats-box nats-rply

# pulumi environment
ENV PATH=${PATH}:/usr/local/pulumi \
    PULUMI_HOME=/usr/local/pulumi \
    PULUMI_SKIP_UPDATE_CHECK=1

COPY .profile $WORKDIR

LABEL PULUMI_VERSION=v${PULUMI_VERSION} \
      NODE_VERSION=${NODE_VERSION} \
      NATS_BOX=${NATS_PROVIDER_VERSION}
