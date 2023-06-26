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

The following version are available:

| Tag | Alpine | PHP | NGINX |
| --- | --- | --- | --- |
| Latest | 3.18.2 | 8.2.7 | 1.24.0 |
| 8.2 | 3.18.2 | 8.2.7 | 1.24.0 |

If you need another version, you can fork and edit the `Dockerfile` and then build for your own.
