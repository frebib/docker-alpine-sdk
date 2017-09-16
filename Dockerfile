ARG IMAGE=alpine
ARG TAG=3.6

FROM ${IMAGE}:${TAG}

SHELL ["/bin/sh", "-exc"]

RUN apk add --no-cache alpine-sdk tree su-exec sudo

RUN mkdir -p /var/cache/distfiles && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    \
    { \
    echo '#!/bin/sh'; \
    echo 'set -e'; \
    echo ; \
    echo 'if [ -z "$USER" ]; then'; \
    echo '    >&2 echo "Error: $USER variable is unset"'; \
    echo '    exit 92'; \
    echo 'fi'; \
    echo ; \
    echo 'adduser -D $USER'; \
    echo 'addgroup $USER abuild'; \
    echo 'echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers'; \
    echo ; \
    echo '# Start in user home directory' ; \
    echo 'cd "$(getent passwd $USER | cut -d: -f6)"' ; \
    echo ; \
    echo 'exec su-exec $USER:abuild "$@"' ; \
    } > /usr/local/bin/init-abuild && \
    \
    chmod 755 /usr/local/bin/init-abuild

ENTRYPOINT ["/usr/local/bin/init-abuild"]

CMD ["/bin/sh"]
