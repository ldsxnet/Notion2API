#!/bin/sh
set -eu

CONFIG_PATH="${NOTION2API_CONFIG_PATH:-/app/data/config.json}"
DEFAULT_CONFIG_PATH="${NOTION2API_DEFAULT_CONFIG_PATH:-/app/config/config.default.json}"

if [ ! -f "$CONFIG_PATH" ] && [ -f "$DEFAULT_CONFIG_PATH" ]; then
  mkdir -p "$(dirname "$CONFIG_PATH")"
  cp "$DEFAULT_CONFIG_PATH" "$CONFIG_PATH"
  echo "[entrypoint] $CONFIG_PATH not found; copied default template from $DEFAULT_CONFIG_PATH" >&2
fi

# Override sensitive config values from environment variables (only on first init
# or whenever the env vars are set). This uses sed for lightweight JSON patching
# without requiring jq in the minimal container image.
if [ -f "$CONFIG_PATH" ]; then
  if [ -n "${NOTION2API_API_KEY:-}" ]; then
    sed -i "s|\"api_key\":.*|\"api_key\": \"${NOTION2API_API_KEY}\",|" "$CONFIG_PATH"
    echo "[entrypoint] api_key overridden from NOTION2API_API_KEY env" >&2
  fi
  if [ -n "${NOTION2API_ADMIN_PASSWORD:-}" ]; then
    sed -i "s|\"password\":.*|\"password\": \"${NOTION2API_ADMIN_PASSWORD}\",|" "$CONFIG_PATH"
    echo "[entrypoint] admin.password overridden from NOTION2API_ADMIN_PASSWORD env" >&2
  fi
fi

exec "$@"
