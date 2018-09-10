ARG IMAGE=spritsail/alpine
ARG ALPINE_TAG=3.8

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
    sed -i "/PS1=/c\\\\export PS1='\\\\e[1;36m\\\\u@\\\\h\\\\e[0m \\\\e[0;32m\$(ppwd)\\\\e[0m> '" /etc/profile

ADD https://gist.githubusercontent.com/frebib/2b4ba154a9d62b31b1edcb50477e7f01/raw/647c3f8ee4dc7e325cd41f40fe47735f75a7f607/ppwd.sh /usr/bin/ppwd
RUN chmod 755 /usr/bin/ppwd

ENV ENV=/etc/profile
ENV GPG_TTY=/dev/console

ENTRYPOINT ["/usr/local/bin/init-abuild"]
CMD ["/bin/sh"]
