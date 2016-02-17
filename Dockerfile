FROM ruby:2.2.0
MAINTAINER Nick Bryant <nick@nativesync.io>
WORKDIR /nativeapi

RUN apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq install \
        build-essential \
        git \
        libpq-dev \
        vim \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq autoremove \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq autoclean \
    && DEBIAN_FRONTEND=noninteractive apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/nativeapi/bin/entrypoint" ]
CMD [ "rackup", "config.ru" ]
