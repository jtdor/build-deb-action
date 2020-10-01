FROM ${BUILD_FROM}

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes dpkg-dev

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
