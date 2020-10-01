FROM debian:stable-slim

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes dpkg-dev

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
