FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic

ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config" \
  BISQ_VERSION="1.9.11"

RUN echo "**** Install dependencies ****" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl jq ca-certificates git git-lfs openjdk-17-jdk && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/BISQ

RUN echo "**** Using Bisq version: $BISQ_VERSION ****" && \
    git clone --depth 1 --branch v$BISQ_VERSION https://github.com/bisq-network/bisq . && \
    cd bisq && \
    ./gradlew build

RUN echo "**** Set up machine ID for dbus ****" && \
    dbus-uuidgen > /etc/machine-id

COPY root/ /

EXPOSE 8080

CMD ["/init"]
