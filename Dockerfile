ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION}

LABEL maintainer = "https://hub.docker.com/u/jones2748"

COPY ./entrypoint.sh /usr/local/bin

RUN set -euxo pipefail ;\
    sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories ;\
    apk add --no-cache --update python3 ca-certificates openssh-client sshpass dumb-init ;\
    apk add --no-cache --update --virtual .build-deps python3-dev build-base libffi-dev openssl-dev ;\
    pip3 install --no-cache --upgrade pip ;\
    pip3 install --no-cache --upgrade setuptools ansible ;\
    apk del --no-cache --purge .build-deps ;\
    rm -rf /var/cache/apk/* ;\
    rm -rf /root/.cache ;\
    ln -s /usr/bin/python3 /usr/bin/python ;\
    mkdir -p /etc/ansible/ ;\
    /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts ;\
    ssh-keygen -q -t ed25519 -N '' -f /root/.ssh/id_ed25519 ;\
    mkdir -p ~/.ssh && echo "Host *" > ~/.ssh/config && echo " StrictHostKeyChecking no" >> ~/.ssh/config ;\
    chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /ansible

ENTRYPOINT ["/usr/bin/dumb-init","--","entrypoint.sh"]
CMD ["/bin/sh"]