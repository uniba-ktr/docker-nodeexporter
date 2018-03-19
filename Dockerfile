ARG IMAGE_TARGET=alpine

# first image to download qemu and make it executable
FROM alpine AS qemu
ARG QEMU=x86_64
ARG QEMU_VERSION=v2.11.0
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static

# second image to be deployed on dockerhub
FROM ${IMAGE_TARGET}
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
ARG ARCH=amd64
ARG NODEEXPORTER_ARCH=amd64
ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

RUN apk add -U --no-cache curl && \
    curl -sL https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-${NODEEXPORTER_ARCH}.tar.gz \
    | tar -xzf - && \
    cd node_exporter-* && \
    cp node_exporter /bin/node_exporter && \
    rm -r /node_exporter-*

USER       root
EXPOSE     9100

COPY config /etc/node_exporter
RUN chmod +x /etc/node_exporter/docker-entrypoint.sh
ENTRYPOINT [ "/etc/node_exporter/docker-entrypoint.sh" ]

LABEL de.uniba.ktr.node-exporter.version=$VERSION \
      de.uniba.ktr.node-exporter.name="Node exporter" \
      de.uniba.ktr.node-exporter.docker.cmd="docker run --publish=9100:9100 --detach=true --name=nodeexporter --net=\"host\" --pid=\"host\" -v /etc/hostname:/etc/nodename:ro unibaktr/nodeexporter" \
      de.uniba.ktr.node-exporter.vendor="Marcel Grossmann" \
      de.uniba.ktr.node-exporter.architecture=$ARCH \
      de.uniba.ktr.node-exporter.vcs-ref=$VCS_REF \
      de.uniba.ktr.node-exporter.vcs-url=$VCS_URL \
      de.uniba.ktr.node-exporter.build-date=$BUILD_DATE
