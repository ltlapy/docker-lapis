FROM debian:buster-slim

LABEL org.opencontainers.image.source="https://github.com/ltlapy/docker-lapis" \
    repository="https://github.com/ltlapy/docker-lapis" \
    maintainer="ltlapy <github.com/ltlapy>"\
    origin_repo="https://github.com/MilesChou/docker-lapis"

# Ref https://github.com/openresty/docker-openresty/blob/master/alpine/Dockerfile
ARG OPENRESTY_CONFIG_OPTIONS="\
    --with-http_auth_request_module \
    --with-http_gunzip_module \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-ipv6 \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    "

# Set environment
ENV OPENRESTY_VERSION=1.21.4.1 \
    OPENRESTY_PREFIX=/usr/local/openresty \
    LUAROCKS_VERSION=3.9.2 \
    LAPIS_VERSION=1.12.0-1
ENV PATH=${OPENRESTY_PREFIX}/bin:${OPENRESTY_PREFIX}/nginx/sbin:${PATH}

LABEL OPENRESTY_VERSION=$OPENRESTY_VERSION \
    LUAROCKS_VERSION=$LUAROCKS_VERSION \
    LAPIS_VERSION=$LAPIS_VERSION

# Set Persistent Deps
ENV BUILD_DEPS \
        build-essential \
        git-core \
        unzip \
        wget

COPY docker-luarocks-install /usr/local/bin/

# Install depandency packages
RUN set -xe && \
        apt-get update -y && apt-get install -y --no-install-recommends --no-install-suggests \
            ${BUILD_DEPS} \
            ca-certificates \
            libpcre3-dev \
            libssl-dev \
            zlib1g-dev 

# Install OpenResty
RUN wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
    tar xf openresty-${OPENRESTY_VERSION}.tar.gz && rm -f openresty-${OPENRESTY_VERSION}.tar.gz && \
    cd openresty-${OPENRESTY_VERSION} && \
    ./configure \
        ${OPENRESTY_CONFIG_OPTIONS} \
    && \
    make -j $(getconf _NPROCESSORS_ONLN) && make install && \
    cd / && rm -rf openresty-${OPENRESTY_VERSION} && \
    # Create link
    [ -e /usr/local/bin/luajit ] || ln -sf /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit

# Install LuaRocks
RUN wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar zxf luarocks-${LUAROCKS_VERSION}.tar.gz && rm -f luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
    ./configure \
        --with-lua=${OPENRESTY_PREFIX}/luajit \
        --with-lua-include=${OPENRESTY_PREFIX}/luajit/include/luajit-2.1 \
        --with-lua-lib=${OPENRESTY_PREFIX}/lualib \
    && \
    make -j $(getconf _NPROCESSORS_ONLN) build && make install && \
    cd / && rm -rf luarocks-${LUAROCKS_VERSION}

# Install Lapis
RUN docker-luarocks-install lapis ${LAPIS_VERSION} && \
    docker-luarocks-install moonscript && \
    # Remove build deps
    # apt-get remove --purge -y ${BUILD_DEPS} && apt-get autoremove --purge -y && rm -r /var/lib/apt/lists/* && \
    # Test
    lapis -h

RUN mkdir /app
WORKDIR /app
CMD [ "lapis", "server" ]