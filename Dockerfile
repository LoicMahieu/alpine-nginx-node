FROM alpine:3.2

MAINTAINER Loïc Mahieu <mahieuloic@gmail.com>

#### Node.js
ENV NODE_VERSION v4.2.1
RUN apk add --update curl make gcc g++ python linux-headers paxctl libgcc libstdc++ && \
  curl -sSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz | tar -xz && \
  cd /node-${NODE_VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  make install && \
  paxctl -cm /usr/bin/node && \
  cd / && \
  if [ -x /usr/bin/npm ]; then \
    npm install -g npm@2 && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del curl make gcc g++ python linux-headers paxctl ${DEL_PKGS} && \
  rm -rf /etc/ssl /node-${NODE_VERSION} ${RM_DIRS} \
    /usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html && \
  echo "\
rm -rf /tmp/* \
       /root/.npm \
       /usr/bin/npm \
       /usr/bin/node \
       /usr/include/node \
       /usr/lib/node_modules \
       /usr/share/man \
       /usr/share/doc \
       /usr/bin/uninstall_node \
" > /usr/bin/uninstall_node && chmod +x /usr/bin/uninstall_node

#### NGINX
ENV NGINX_VERSION nginx-1.9.5
RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    apk del wget build-base && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*

VOLUME ["/var/log/nginx"]
CMD ["nginx", "-g", "daemon off;"]

# Clean
RUN rm -rf /scripts
