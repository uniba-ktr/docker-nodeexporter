FROM alpine
ARG TARGETPLATFORM=amd64
ARG VERSION=0.17.0
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

RUN apk add -U --no-cache curl && \
    curl -sL https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-$(echo ${TARGETPLATFORM} | sed -e "s|arm32v5|armv5|g" -e "s|arm32v6|armv6|g" -e "s|arm32v7|armv7|g" -e "s|arm64.*|arm64|g" -e "s|i386|386|g").tar.gz \
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
      de.uniba.ktr.node-exporter.architecture=$TARGETPLATFORM \
      de.uniba.ktr.node-exporter.vcs-ref=$VCS_REF \
      de.uniba.ktr.node-exporter.vcs-url=$VCS_URL \
      de.uniba.ktr.node-exporter.build-date=$BUILD_DATE
