# docker-alpine-nginx-php

![GitHub workflow](https://github.com/thesuhu/docker-alpine-nginx-php/actions/workflows/docker-image.yml/badge.svg) ![Docker pull](https://img.shields.io/docker/pulls/thesuhu/docker-alpine-nginx-php)

Docker image to run PHP and Nginx.

## Usage

Pull the latest image from Docker hub.

```sh
docker pull thesuhu/docker-alpine-nginx-php:<version>
```

If you want to serve your web directly from host, just mount your web directory into container. Example:

```sh
docker run -itd -p 8080:80 --name myweb -v ~/myweb:/var/www/html thesuhu/docker-alpine-nginx-php:<version>
```

Or if you just want to try to see the PHP default configuration, run the following command and open the web through your browser.

```sh
docker run -itd -p 8080:80 --name myweb thesuhu/docker-alpine-nginx-php:<version>
```

If you have permission issue with your web directory, try to change the permission to `777` before running container.

```sh
chmod 777 -R myweb
```

Or you can build new image with your web files. Just create `Dockerfile` file and then build new image.

```sh
FROM thesuhu/docker-alpine-nginx-php:<version>

COPY myweb /var/www/html
```

## Release

The current Dockerfile builds the following versions. The workflow publishes image tags `8.3.36`, `8.3`, and `latest` after a successful build:

| Tags | Alpine branch | PHP | NGINX | njs |
| --- | --- | --- | --- | --- |
| `8.3.36`, `8.3`, `latest` | 3.23 | **8.3.36** | **1.30.6 stable** | 1.0.2 |

NGINX and its existing GeoIP, image filter, njs, and XSLT modules are pinned to matching versions from the signed official stable repository. GNU libiconv comes from the matching Alpine stable repository instead of edge; the obsolete `LD_PRELOAD` setting is removed. Composer runs with the base image's PHP rather than installing another PHP runtime through APK. The build checks NGINX and PHP-FPM configuration and runs `composer --version`.

Before publishing, CI starts the container and requests the bundled `phpinfo.php` through NGINX to verify that PHP-FPM serves PHP 8.3.36 over HTTP.

Historical releases (these describe older images and do not include this PHP2Shell update):

| Tag | Alpine | PHP | NGINX |
| --- | --- | --- | --- |
| Latest | 3.20.0 | 8.3.14 | 1.26.2 |
| 8.3 | 3.20.0 | 8.3.14 | 1.26.2 |
| 8.2 | 3.18.2 | 8.2.7 | 1.24.0 |

If you need another version, you can fork and edit the `Dockerfile` and then build for your own.

## PHP2Shell security update

PHP 8.3.36 includes fixes for PHP2Shell (CVE-2026-109618 and CVE-2026-109619). See the [PHP release announcement](https://www.php.net/releases/8_3_36.php) and [Docker security advisory](https://www.docker.com/blog/security-update-on-php2shell-impact-for-docker-customers/).

Rebuild and check the image before deploying:

```sh
docker build --pull --no-cache -t thesuhu/docker-alpine-nginx-php:8.3.36 .
docker run --rm --entrypoint php thesuhu/docker-alpine-nginx-php:8.3.36 -v
docker run --rm --entrypoint nginx thesuhu/docker-alpine-nginx-php:8.3.36 -v
docker run --rm --entrypoint nginx thesuhu/docker-alpine-nginx-php:8.3.36 -t
docker run --rm --entrypoint php-fpm thesuhu/docker-alpine-nginx-php:8.3.36 -t
```

Recreate deployed containers using the rebuilt image and the same volumes, environment, ports, and networks. Restarting a container based on the old image does not apply the patch. Verify the running container:

```sh
docker exec myweb php -v
```

The PHP version should be 8.3.36. Test application routing, sessions, cache behavior, and HTTPS behind the load balancer before switching production traffic. The base OS changes from Alpine 3.20 to 3.23; check any additional native PHP extensions and custom njs scripts against the new libraries and njs 1.0.2. Existing NGINX configuration is retained.

The historical `8.2` image is not rebuilt by this workflow. Applications using it must migrate to a patched image or receive a separate PHP 8.2 update.
