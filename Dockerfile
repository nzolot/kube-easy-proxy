FROM nginx:1.21-alpine

ENV STATUS_PORT="80"
ENV WHITELIST=""
ENV DEBUG="false"

#ENV PROXY_CONFIG="http,8080,http://localhost:80;tcp,8081,localhost:80"
ENV PROXY_CONFIG=""
ENV PROXY_PROTOCOL="http"
ENV PROXY_PORTS="8080"
ENV PROXY_TARGET="http://localhost"

RUN mkdir /etc/nginx/conf.d/http && \
    mkdir /etc/nginx/conf.d/tcp
COPY files/templates /etc/nginx/templates
COPY files/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
