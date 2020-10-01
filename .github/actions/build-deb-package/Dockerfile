ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apt-get update --quiet \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --quiet --yes dpkg-dev

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
