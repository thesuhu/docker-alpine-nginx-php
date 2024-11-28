FROM php:8.3.14-fpm-alpine3.20

# Tambahkan library tambahan untuk PHP
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv

# Versi NGINX yang digunakan
ENV NGINX_VERSION 1.26.2
ENV PKG_RELEASE 1
ENV NJS_VERSION 0.8.7

# Setup user dan grup untuk NGINX
RUN set -x \
    && addgroup -g 1020 -S nginx && adduser -S -D -H -u 1020 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Unduh dan instal NGINX dan modul-modulnya secara manual
RUN wget -q https://nginx.org/packages/alpine/v3.20/main/x86_64/nginx-${NGINX_VERSION}-r${PKG_RELEASE}.apk && \
    wget -q https://nginx.org/packages/alpine/v3.20/main/x86_64/nginx-module-geoip-${NGINX_VERSION}-r2.apk && \
    wget -q https://nginx.org/packages/alpine/v3.20/main/x86_64/nginx-module-image-filter-${NGINX_VERSION}-r2.apk && \
    wget -q https://nginx.org/packages/alpine/v3.20/main/x86_64/nginx-module-njs-${NGINX_VERSION}.${NJS_VERSION}-r1.apk && \
    wget -q https://nginx.org/packages/alpine/v3.20/main/x86_64/nginx-module-xslt-${NGINX_VERSION}-r2.apk && \
    apk add --allow-untrusted ./nginx-${NGINX_VERSION}-r${PKG_RELEASE}.apk && \
    apk add --allow-untrusted ./nginx-module-geoip-${NGINX_VERSION}-r2.apk && \
    apk add --allow-untrusted ./nginx-module-image-filter-${NGINX_VERSION}-r2.apk && \
    apk add --allow-untrusted ./nginx-module-njs-${NGINX_VERSION}.${NJS_VERSION}-r1.apk && \
    apk add --allow-untrusted ./nginx-module-xslt-${NGINX_VERSION}-r2.apk && \
    rm -f *.apk

# Install alat tambahan
RUN apk add --no-cache curl ca-certificates tzdata composer supervisor

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

# Expose port untuk NGINX
EXPOSE 80
STOPSIGNAL SIGTERM

# Konfigurasi entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
