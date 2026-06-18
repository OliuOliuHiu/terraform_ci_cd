#!/bin/sh
set -eu

IMAGE="${1:?Usage: deploy.sh <image> <nginx_conf_path>}"
NGINX_CONF_SOURCE="${2:?Usage: deploy.sh <image> <nginx_conf_path>}"

APP_CONTAINER="lab-02-tera-app"
NGINX_CONTAINER="lab-02-tera-nginx"
NETWORK="tera-net"
DEPLOY_DIR="/opt/lab-02-tera"
NGINX_CONF_TARGET="${DEPLOY_DIR}/nginx.conf"

until command -v docker >/dev/null 2>&1 && systemctl is-active --quiet docker; do
  echo "Waiting for Docker..."
  sleep 10
done

docker network create "${NETWORK}" >/dev/null 2>&1 || true

mkdir -p "${DEPLOY_DIR}"
cp "${NGINX_CONF_SOURCE}" "${NGINX_CONF_TARGET}"

docker pull "${IMAGE}"

docker stop "${NGINX_CONTAINER}" "${APP_CONTAINER}" >/dev/null 2>&1 || true
docker rm "${NGINX_CONTAINER}" "${APP_CONTAINER}" >/dev/null 2>&1 || true

docker run -d \
  --name "${APP_CONTAINER}" \
  --network "${NETWORK}" \
  --restart unless-stopped \
  "${IMAGE}"

docker run -d \
  --name "${NGINX_CONTAINER}" \
  --network "${NETWORK}" \
  --restart unless-stopped \
  -p 80:80 \
  -v "${NGINX_CONF_TARGET}:/etc/nginx/conf.d/default.conf:ro" \
  nginx:1.27-alpine

docker image prune -f
