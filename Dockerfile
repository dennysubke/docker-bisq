FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config"

RUN echo "**** Install dependencies ****" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl jq ca-certificates git git-lfs openjdk-17-jdk && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/BISQ

RUN echo "**** Fetch latest Bisq release ****" && \
    BISQ_RELEASE=$(curl -s "https://api.github.com/repos/bisq-network/bisq/releases/latest" | jq -r .tag_name | cut -c2-) && \
    git clone --depth 1 --branch v${BISQ_RELEASE} https://github.com/bisq-network/bisq . && \
    ./gradlew build

RUN echo "**** Set up machine ID for dbus ****" && \
    dbus-uuidgen > /etc/machine-id

COPY root/ /

EXPOSE 8080

CMD ["/init"]
