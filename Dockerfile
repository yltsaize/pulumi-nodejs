FROM node:14.19.3-alpine

RUN apk add --update make

RUN wget -O pulumi.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v3.37.2-linux-x64.tar.gz \
    && tar -zxf pulumi.tar.gz \
    && mkdir -p /usr/local/pulumi \
    && cp pulumi/pulumi pulumi/pulumi-language-nodejs pulumi/pulumi-resource-pulumi-nodejs /usr/local/pulumi/ \
    && rm pulumi.tar.gz \
    && rm -rf pulumi/ \
    && mkdir -p /usr/local/pulumi/plugins/resource-minio-v0.4.1 \
    && cd /usr/local/pulumi/plugins/resource-minio-v0.4.1 \
    && wget -O pulumi-resource-minio.tar.gz https://github.com/pulumi/pulumi-minio/releases/download/v0.4.1/pulumi-resource-minio-v0.4.1-linux-amd64.tar.gz \
    && tar -zxf pulumi-resource-minio.tar.gz \
    && rm pulumi-resource-minio.tar.gz

ENV PATH=${PATH}:/usr/local/pulumi \
    PULUMI_HOME=/usr/local/pulumi \
    PULUMI_SKIP_UPDATE_CHECK=1

LABEL PULUMI_VERSION=v3.36.0 \
      NODE_VERSION=14.19.3

