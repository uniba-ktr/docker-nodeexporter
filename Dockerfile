ARG IMAGE_TARGET=alpine

# first image to download qemu and make it executable
FROM alpine AS qemu
ARG QEMU=x86_64
ADD https://github.com/multiarch/qemu-user-static/releases/download/v2.11.0/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static


# second image to be deployed on dockerhub
FROM ${IMAGE_TARGET}
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
ARG ARCH=amd64
ARG PROMETHEUS_ARCH=amd64
ARG VERSION=2.2.0
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

ADD https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-${PROMETHEUS_ARCH}.tar.gz /tmp/node_exporter.tar.gz

RUN cd /tmp && tar xzf /tmp/node_exporter.tar.gz && \
    mv node_exporter-* node_exporter && \
    cp node_exporter/node_exporter /bin/node_exporter && \
    cd / && \
    rm -rf /tmp

USER       nobody
EXPOSE     9100

ENTRYPOINT [ "/bin/node_exporter" ]

LABEL de.uniba.ktr.node-exporter.version=$VERSION \
      de.uniba.ktr.node-exporter.name="Prometheus" \
      de.uniba.ktr.node-exporter.docker.cmd="docker run --publish=9100:9100 --detach=true --name=nodeexporter --net=\"host\" --pid=\"host\" unibaktr/nodeexporter" \
      de.uniba.ktr.node-exporter.vendor="Marcel Grossmann" \
      de.uniba.ktr.node-exporter.architecture=$ARCH \
      de.uniba.ktr.node-exporter.vcs-ref=$VCS_REF \
      de.uniba.ktr.node-exporter.vcs-url=$VCS_URL \
      de.uniba.ktr.node-exporter.build-date=$BUILD_DATE
