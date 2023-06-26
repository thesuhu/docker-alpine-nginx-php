FROM php:8.2.7-fpm-alpine3.18

RUN apk update \
    && apk add --no-cache nginx supervisor git curl

# config
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/supervisord.conf /etc/supervisord.conf

# default page
COPY ./www/index.php /var/www/html/index.php
COPY ./www/phpinfo.php /var/www/html/phpinfo.php

# scripts
COPY ./scripts/configure.sh /configure.sh

EXPOSE 80/tcp

RUN chmod +x /configure.sh && sh /configure.sh

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
