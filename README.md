
# Docker image: alpine-nginx-node

Example:
```
FROM loicmahieu/alpine-nginx-node

RUN apk --update add git make gcc g++ python

RUN mkdir -p /tmp/build-app
COPY package.json /tmp/build-app/package.json
RUN cd /tmp/build-app && \
    npm install
COPY . /tmp/build-app
RUN cd /tmp/build-app && \
    npm run build && \
    mv /tmp/build-app/build /app && \
    apk del git make gcc g++ python && \
    rm -rf /tmp/* \
           /var/cache/apk/* && \
    /usr/bin/uninstall_node
WORKDIR /app

#### NGINX CONF
COPY ./nginx/nginx.conf /etc/nginx/conf/nginx.conf

EXPOSE 80
```
