FROM node:14.19.3-alpine

RUN wget -O pulumi.tar.gz https://get.pulumi.com/releases/sdk/pulumi-v3.37.2-linux-x64.tar.gz \
    && tar -zxf pulumi.tar.gz \
    && mkdir -p /usr/local/pulumi \
    && cp pulumi/pulumi pulumi/pulumi-language-nodejs pulumi/pulumi-resource-pulumi-nodejs /usr/local/pulumi/ \
    && rm pulumi.tar.gz \
    && rm -rf pulumi/

ENV PATH=${PATH}:/usr/local/pulumi \
    PULUMI_HOME=/usr/local/pulumi \
    PULUMI_SKIP_UPDATE_CHECK=1

LABEL PULUMI_VERSION=v3.36.0 \
      NODE_VERSION=14.19.3

