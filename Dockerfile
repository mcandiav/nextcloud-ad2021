ARG NEXTCLOUD_IMAGE=nextcloud:32.0.2
FROM ${NEXTCLOUD_IMAGE}

LABEL org.opencontainers.image.title="Nextcloud AD2021"
LABEL org.opencontainers.image.description="Imagen corporativa derivada de Nextcloud para ad2021.local con soporte SMB/CIFS"
LABEL org.opencontainers.image.vendor="At-Once"

USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        smbclient \
        libsmbclient-dev \
        $PHPIZE_DEPS \
    ; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; \
    apt-get purge -y --auto-remove \
        libsmbclient-dev \
        $PHPIZE_DEPS \
    ; \
    apt-get install -y --no-install-recommends libsmbclient0; \
    rm -rf /var/lib/apt/lists/* /tmp/pear; \
    php -m | grep -Fx smbclient; \
    command -v smbclient; \
    smbclient --version
