FROM php:8.3.14-fpm-alpine3.20

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Tambahkan gnu-libiconv
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv

# Versi NGINX dan NJS
ENV NGINX_VERSION 1.26.2
ENV NJS_VERSION 0.8.7

# Setup NGINX dan modul-modulnya
RUN set -x \
    && addgroup -g 1020 -S nginx && adduser -S -D -H -u 1020 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && KEY_SHA512=$(sha512sum /tmp/nginx_signing.rsa.pub | awk '{print $1}') \
    && if [ "$KEY_SHA512" != "e09fa32f0a0eab2b879ccbbc4d0e4fb9751486eedda75e35fac65802cc9faa266425edf83e261137a2f4d16281ce2c1a5f4502930fe75154723da014214f0655" ]; then \
         echo "Key verification failed!"; exit 1; \
    fi \
    && mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
    && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache \
        nginx=${NGINX_VERSION} \
        nginx-module-xslt=${NGINX_VERSION} \
        nginx-module-geoip=${NGINX_VERSION} \
        nginx-module-image-filter=${NGINX_VERSION} \
        nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION} \
    && apk add --no-cache curl ca-certificates \
    && apk add --no-cache tzdata \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir /docker-entrypoint.d

# Install alat tambahan
RUN apk add composer supervisor

# Copy konfigurasi dan skrip
COPY www-example/*.php /var/www/html/
COPY www-example/*.html /var/www/html/
COPY scripts/docker-entrypoint.sh /
COPY scripts/*.sh /docker-entrypoint.d/

RUN chmod +x -R /docker-entrypoint.d && chmod +x /docker-entrypoint.sh

# Konfigurasi supervisord dan nginx
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-default.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
