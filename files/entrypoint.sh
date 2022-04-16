#!/usr/bin/env sh

if [ "x${DEBUG}" == "xtrue" ]; then
  set -x
fi

echo "Copy nginx.conf"
cp /etc/nginx/templates/nginx.conf /etc/nginx/nginx.conf

echo "Cleaning up http and tcp dirs"
rm -f /etc/nginx/conf.d/http/*
rm -f /etc/nginx/conf.d/tcp/*

echo "Processing status template"
cp /etc/nginx/templates/nginx_status.tpl /etc/nginx/conf.d/http/nginx_status.conf
sed -i "s#xSTATUS_PORTx#${STATUS_PORT}#g" /etc/nginx/conf.d/http/nginx_status.conf

echo "Generating PROXY_CONFIG"
# "http,8080,http://localhost:80; tcp,8081,localhost:80"
if [ "x${PROXY_PROTOCOL}" != "x" ] && [ "x${PROXY_PORTS}" != "x" ] && [ "x${PROXY_TARGET}" != "x" ]; then
  IFS=','
  for PORT in ${PROXY_PORTS}; do
    PROXY_CONFIG="${PROXY_PROTOCOL},${PORT},${PROXY_TARGET}:${PORT};${PROXY_CONFIG}"
  done
fi

echo "Processing proxies list"
IFS=';'
for CONFIG in ${PROXY_CONFIG}; do
  SERVER_TYPE=$(echo ${CONFIG} | awk -F',' {'print $1'})
  LISTEN_PORT=$(echo ${CONFIG} | awk -F',' {'print $2'})
  PROXY_PASS=$( echo ${CONFIG} | awk -F',' {'print $3'})
  CONFIG_NAME=$(echo ${CONFIG} | md5sum | awk {'print $1'})
  echo "CONFIG_NAME=${CONFIG_NAME} SERVER_TYPE=${SERVER_TYPE}, LISTEN_PORT=${LISTEN_PORT}, PROXY_PASS=${PROXY_PASS}"
  cp /etc/nginx/templates/nginx_conf_${SERVER_TYPE}.tpl /etc/nginx/conf.d/${SERVER_TYPE}/${CONFIG_NAME}.conf

  sed -i "s#xLISTEN_PORTx#${LISTEN_PORT}#g" /etc/nginx/conf.d/${SERVER_TYPE}/${CONFIG_NAME}.conf
  sed -i "s#xPROXY_PASSx#${PROXY_PASS}#g" /etc/nginx/conf.d/${SERVER_TYPE}/${CONFIG_NAME}.conf

  if [ "x${WHITELIST}" == "x" ];then
    sed -i "s#xWHITELISTx##g" /etc/nginx/conf.d/${SERVER_TYPE}/${CONFIG_NAME}.conf
  else
    IFS=','
    WHITELIST_CONTENT=
    for IP in ${WHITELIST}; do
      WHITELIST_CONTENT="allow ${IP}; ${WHITELIST_CONTENT}"
    done
    WHITELIST_CONTENT="${WHITELIST_CONTENT} deny all;"
    sed -i "s#xWHITELISTx#${WHITELIST_CONTENT}#g" /etc/nginx/conf.d/${SERVER_TYPE}/${CONFIG_NAME}.conf
  fi
done

if [ "x${DEBUG}" == "xtrue" ]; then
echo "---"
cat /etc/nginx/nginx.conf
echo "---"
ls -l /etc/nginx/conf.d/http
cat /etc/nginx/conf.d/http/*
echo "---"
ls -l /etc/nginx/conf.d/tcp
cat /etc/nginx/conf.d/tcp/*
echo "---"
fi
/docker-entrypoint.sh "$@"

