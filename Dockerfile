ARG PHP_VERSION=8.3.36
FROM php:${PHP_VERSION}-fpm-alpine3.23

# Gunakan library dari repository Alpine yang sesuai dengan base image.
RUN apk add --no-cache gnu-libiconv

# Versi NGINX stable dan modul yang kompatibel.
ENV NGINX_VERSION=1.30.6
ENV PKG_RELEASE=1
ENV NJS_VERSION=1.0.2

# Setup user dan grup untuk NGINX
RUN set -x \
    && addgroup -g 1020 -S nginx && adduser -S -D -H -u 1020 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Instal paket bertanda tangan dari repository resmi NGINX stable.
RUN wget -q -O /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && echo "@nginx https://nginx.org/packages/alpine/v3.23/main" >> /etc/apk/repositories \
    && apk add --no-cache \
        "nginx@nginx=${NGINX_VERSION}-r${PKG_RELEASE}" \
        "nginx-module-geoip@nginx=${NGINX_VERSION}-r${PKG_RELEASE}" \
        "nginx-module-image-filter@nginx=${NGINX_VERSION}-r${PKG_RELEASE}" \
        "nginx-module-njs@nginx=${NGINX_VERSION}.${NJS_VERSION}-r${PKG_RELEASE}" \
        "nginx-module-xslt@nginx=${NGINX_VERSION}-r${PKG_RELEASE}"

# Install alat tambahan
RUN apk add --no-cache curl ca-certificates tzdata supervisor gettext

# Gunakan PHP dari base image untuk Composer, tanpa instalasi PHP tambahan dari APK.
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Konfigurasi logging untuk NGINX
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /docker-entrypoint.d /var/log/supervisor

# Copy file konfigurasi dan script
COPY www-example/*.php /var/www/html/
COPY www-example/*.html /var/www/html/
COPY scripts/docker-entrypoint.sh /
COPY scripts/10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY scripts/20-envsubst-on-templates.sh /docker-entrypoint.d
COPY scripts/30-tune-worker-processes.sh /docker-entrypoint.d

# Copy konfigurasi supervisord dan NGINX
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-default.conf /etc/nginx/conf.d/default.conf

# Beri izin eksekusi pada skrip
RUN chmod +x -R /docker-entrypoint.d && chmod +x /docker-entrypoint.sh

RUN nginx -t && php-fpm -t && composer --version

# Expose port untuk NGINX
EXPOSE 80
STOPSIGNAL SIGTERM

# Konfigurasi entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
