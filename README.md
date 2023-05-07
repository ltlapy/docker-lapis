# Docker Lapis

[![](https://img.shields.io/docker/stars/lapytopy/lapis.svg)](https://hub.docker.com/r/lapytopy/lapis/) [![](https://img.shields.io/docker/pulls/lapytopy/lapis.svg)](https://hub.docker.com/r/lapytopy/lapis/)

Docker base image for Lapis, see https://hub.docker.com/r/lapytopy/lapis/, based on [MilesChou](https://github.com/MilesChou/docker-lapis)'s Dockerfile.

The repository is a simple image with [OpenResty](https://openresty.org/en/) and [Lapis Framework](http://leafo.net/lapis/).

## What's different from origin repository
- arm64 Images *(most important)*
- Updated lapis and luarocks
- Doesn't remove build deps, to prevent some rocks failing to install

## Usage for GitHub Container Registry

See [GitHub Container Registry](https://github.com/users/MilesChou/packages/container/package/lapis)

### For development
#### Create a basic application with moonscript

```bash
docker run \
  -w /app \
  --mount type=bind,source="$(pwd)"/src,target=/app \
  --rm -it ghcr.io/ltlapy/docker-lapis:debian \
  lapis new --moonscript
```

#### Run directly from lapis image

```bash
docker run \
  -w /app \
  -p 8080 \
  --mount type=bind,source="$(pwd)"/src,target=/app \
  --rm -it lapytopy/lapis:latest \
  /bin/bash -c "moonc . && lapis server"
```

> **Note**
> You can pin your dependencies by running following commands, for prevent dependency corruption:
> `luarocks build --only-deps` 

> **Warning**
> If you can't access to the service while running, try changing port number to another.

## Supported tags and respective `Dockerfile` links

* [`latest`, `debian` (Dockerfile)](https://github.com/MilesChou/docker-lapis/blob/master/Dockerfile)
* [`alpine` (alpine/Dockerfile)](https://github.com/MilesChou/docker-lapis/blob/master/alpine/Dockerfile) (TODO)

## Thanks

* [GitHub](https://github.com/)
* [Docker Hub](https://hub.docker.com/)
* [MilesChou](https://github.com/MilesChou) ([origin repo](https://github.com/MilesChou/docker-lapis))
