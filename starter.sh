#!/bin/sh
set -eu

if [ -z "${VLESS_UUID:-}" ]; then
  echo "Erreur : la variable VLESS_UUID doit être définie."
  exit 1
fi

envsubst '${VLESS_UUID}' < /etc/xray/config.template.json > /tmp/xray-config.json

xray run -config /tmp/xray-config.json &
XRAY_PID=$!

nginx -g 'daemon off;' &
NGINX_PID=$!

cleanup() {
  kill "$XRAY_PID" "$NGINX_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

while kill -0 "$XRAY_PID" 2>/dev/null && kill -0 "$NGINX_PID" 2>/dev/null; do
  sleep 2
done
exit 1
