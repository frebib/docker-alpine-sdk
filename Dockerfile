ARG IMAGE=spritsail/alpine
ARG ALPINE_TAG=3.13

FROM ${IMAGE}:${ALPINE_TAG}
ARG ALPINE_TAG

SHELL ["/bin/sh", "-exc"]

ADD skel /

RUN apk add --no-cache alpine-sdk tree gnupg su-exec sudo

RUN mkdir -p /var/cache/distfiles && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    \
    if [ "$ALPINE_TAG" = edge ]; then \
       echo "http://dl-cdn.alpinelinux.org/alpine/$ALPINE_TAG/testing" >> /etc/apk/repositories; \
    fi && \
    chmod 755 /usr/local/bin/init-abuild

ENV GPG_TTY=/dev/console

ENTRYPOINT ["/usr/local/bin/init-abuild"]
CMD ["/bin/sh"]
