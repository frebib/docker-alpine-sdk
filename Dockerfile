ARG IMAGE=alpine
ARG TAG=3.6

FROM ${IMAGE}:${TAG}
ARG TAG

SHELL ["/bin/sh", "-exc"]

RUN apk add --no-cache alpine-sdk tree gnupg su-exec sudo

RUN mkdir -p /var/cache/distfiles && \
    chgrp abuild /var/cache/distfiles && \
    chmod g+w /var/cache/distfiles && \
    \
    if [ "$TAG" = edge ]; then \
       echo "http://dl-cdn.alpinelinux.org/alpine/$TAG/testing" >> /etc/apk/repositories; \
    fi && \
    \
    { \
    echo '#!/bin/sh'; \
    echo 'set -e'; \
    echo ; \
    echo 'if [ -z "$USER" ]; then'; \
    echo '    >&2 echo "Error: \$USER variable is unset"'; \
    echo '    exit 92'; \
    echo 'fi'; \
    echo ; \
    echo 'adduser -D $USER'; \
    echo 'addgroup $USER abuild'; \
    echo 'echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers'; \
    echo ; \
    echo '# Start in user home directory if no CWD set' ; \
    echo '[ -z "$PWD" ] && cd "$(getent passwd $USER | cut -d: -f6)"' ; \
    echo ; \
    echo '# Set accessible permissions on std* and console' ; \
    echo 'chmod 1777 /dev/std*' ; \
    echo '[ -f /dev/console ] && chmod 1777 /dev/console' ; \
    echo ; \
    echo 'if [ -d .abuild ]; then' ; \
    echo "    find .abuild/ -name '*.pub' -maxdepth 1 -exec ln -sf \$PWD/{} /etc/apk/keys +" ; \
    echo 'fi' ; \
    echo 'if [ "$1" = abuild ]; then' ; \
    echo '    apk update' ; \
    echo 'fi' ; \
    echo ; \
    echo 'exec su-exec $USER:abuild "$@"' ; \
    } > /usr/local/bin/init-abuild && \
    \
    chmod 755 /usr/local/bin/init-abuild

# Set ENV as /etc/profile so it is sourced interactively
RUN { \
    echo '# Common interactive aliases' ; \
    echo 'alias ls="ls --color=auto -Fh"' ; \
    echo 'alias ll="ls -l"' ; \
    echo 'alias la="ls -la"' ; \
    echo ; \
    echo 'alias cp="cp -i"' ; \
    echo 'alias mv="mv -i"' ; \
    echo 'alias rm="rm -i"' ; \
    echo ; \
    echo 'alias apk="sudo apk"' ; \
    } >> /etc/profile && \
    \
    sed -i "/PS1=/c\\export PS1='\\\\u@\\\\h \\\\w> '" /etc/profile

ENV ENV=/etc/profile
ENV GPG_TTY=/dev/console

ENTRYPOINT ["/usr/local/bin/init-abuild"]

CMD ["/bin/sh"]
