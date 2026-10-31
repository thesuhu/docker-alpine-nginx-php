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

The workflow builds and smoke-tests both PHP variants from the same Dockerfile. Image tags are published after that variant passes its checks:

| Tags | Alpine branch | PHP | NGINX | njs |
| --- | --- | --- | --- | --- |
| `8.3.36`, `8.3`, `latest` | 3.23 | **8.3.36** | **1.30.6 stable** | 1.0.2 |
| `8.2.35`, `8.2` | 3.23 | **8.2.35** | **1.30.6 stable** | 1.0.2 |

**`latest` always follows PHP 8.3.** The PHP 8.2 job publishes only `8.2.35` and `8.2`. Local builds default to PHP 8.3.36; select PHP 8.2.35 with `--build-arg PHP_VERSION=8.2.35`.

NGINX and its existing GeoIP, image filter, njs, and XSLT modules are pinned to matching versions from the signed official stable repository. GNU libiconv comes from the matching Alpine stable repository instead of edge; the obsolete `LD_PRELOAD` setting is removed. Composer runs with the base image's PHP rather than installing another PHP runtime through APK. The build checks NGINX and PHP-FPM configuration and runs `composer --version`.

Before publishing each variant, CI starts the container and requests the bundled `phpinfo.php` through NGINX to verify that PHP-FPM serves the selected PHP version over HTTP. Each variant builds and publishes independently.

Historical releases (previous contents of these tags, before the PHP2Shell update):

| Tag | Alpine | PHP | NGINX |
| --- | --- | --- | --- |
| Latest | 3.20.0 | 8.3.14 | 1.26.2 |
| 8.3 | 3.20.0 | 8.3.14 | 1.26.2 |
| 8.2 | 3.18.2 | 8.2.7 | 1.24.0 |

If you need another version, you can fork and edit the `Dockerfile` and then build for your own.

## PHP2Shell security update

PHP 8.3.36 and 8.2.35 include fixes for PHP2Shell (CVE-2026-109618 and CVE-2026-109619). See the [PHP 8.3.36 release announcement](https://www.php.net/releases/8_3_36.php), [PHP 8.2.35 release announcement](https://www.php.net/releases/8_2_35.php), and [Docker security advisory](https://www.docker.com/blog/security-update-on-php2shell-impact-for-docker-customers/).

Rebuild and check the image before deploying:

```sh
docker build --pull --no-cache -t thesuhu/docker-alpine-nginx-php:8.3.36 .
docker run --rm --entrypoint php thesuhu/docker-alpine-nginx-php:8.3.36 -v
docker run --rm --entrypoint nginx thesuhu/docker-alpine-nginx-php:8.3.36 -v
docker run --rm --entrypoint nginx thesuhu/docker-alpine-nginx-php:8.3.36 -t
docker run --rm --entrypoint php-fpm thesuhu/docker-alpine-nginx-php:8.3.36 -t
```

For applications that still require PHP 8.2, build the patched variant explicitly:

```sh
docker build --pull --no-cache --build-arg PHP_VERSION=8.2.35 -t thesuhu/docker-alpine-nginx-php:8.2.35 .
docker run --rm --entrypoint php thesuhu/docker-alpine-nginx-php:8.2.35 -v
docker run --rm --entrypoint nginx thesuhu/docker-alpine-nginx-php:8.2.35 -t
docker run --rm --entrypoint php-fpm thesuhu/docker-alpine-nginx-php:8.2.35 -t
```

Recreate deployed containers using the rebuilt image and the same volumes, environment, ports, and networks. Restarting a container based on the old image does not apply the patch. Verify the running container:

```sh
docker exec myweb php -v
```

The PHP version should match the selected variant: 8.3.36 or 8.2.35. Test application routing, sessions, cache behavior, and HTTPS behind the load balancer before switching production traffic. The base OS changes from Alpine 3.20 (previous PHP 8.3 image) or 3.18 (previous PHP 8.2 image) to 3.23; check any additional native PHP extensions and custom njs scripts against the new libraries and njs 1.0.2. Existing NGINX configuration is retained.

Updating the registry tags does not replace running containers. Deployments using `8.2` must pull the updated image and recreate their containers to apply the patch.
