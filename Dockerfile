# nats-box go builder
FROM golang:1.18-alpine AS builder

WORKDIR $GOPATH/src/github.com/nats-io/

RUN apk add -U --no-cache git binutils
RUN go install github.com/nats-io/nats-top@v0.5.2
RUN go install -ldflags="-X main.version=2.7.1" github.com/nats-io/nsc@2.7.1
RUN go install github.com/nats-io/natscli/nats@v0.0.34
RUN go install github.com/nats-io/stan.go/examples/stan-pub@latest
RUN go install github.com/nats-io/stan.go/examples/stan-sub@latest
RUN go install github.com/nats-io/stan.go/examples/stan-bench@latest

# pulumi node base image
FROM node:14.19.3-alpine
# copy from nats-box builder to node image
RUN apk add -U --no-cache ca-certificates figlet
COPY --from=builder /go/bin/* /usr/local/bin/
RUN cd /usr/local/bin/ && \
    ln -s nats-box nats-pub && \
    ln -s nats-box nats-sub && \
    ln -s nats-box nats-req && \
    ln -s nats-box nats-rply
# pulumi resource 
RUN wget -O pulumi.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v3.37.2-linux-x64.tar.gz \
    && tar -zxf pulumi.tar.gz \
    && mkdir -p /usr/local/pulumi \
    && cp pulumi/pulumi pulumi/pulumi-language-nodejs pulumi/pulumi-resource-pulumi-nodejs /usr/local/pulumi/ \
    && rm pulumi.tar.gz \
    && rm -rf pulumi/ \

# nats-box environment
ENV NKEYS_PATH /nsc/nkeys
ENV XDG_DATA_HOME /nsc
ENV XDG_CONFIG_HOME /nsc/.config
# pulumi environment
ENV PATH=${PATH}:/usr/local/pulumi \
    PULUMI_HOME=/usr/local/pulumi \
    PULUMI_SKIP_UPDATE_CHECK=1

COPY .profile $WORKDIR

LABEL PULUMI_VERSION=v3.36.0 \
      NODE_VERSION=14.19.3 \
      NATS_BOX=0.6.0

