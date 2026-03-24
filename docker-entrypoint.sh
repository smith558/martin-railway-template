#!/bin/sh
set -eu

check_only=false
if [ "${1:-}" = "--check" ]; then
  check_only=true
  shift
fi

if [ -z "${DATABASE_URL:-}" ]; then
  echo "error: DATABASE_URL is required. Set DATABASE_URL or wire it from Railway, for example \${{PostGIS.DATABASE_URL}}." >&2
  exit 64
fi

case "${DATABASE_URL}" in
  *"channel_binding=require"*)
    echo "notice: Stripping channel_binding=require from DATABASE_URL (incompatible with Martin v1.3.1)." >&2
    DATABASE_URL=$(echo "${DATABASE_URL}" | sed -e 's/[&?]channel_binding=require//' -e 's/\?&/?/')
    export DATABASE_URL
    ;;
esac

export PORT="${PORT:-3000}"
export MARTIN_WEB_UI="${MARTIN_WEB_UI:-disable}"
export MARTIN_PUBLISH_SCHEMA="${MARTIN_PUBLISH_SCHEMA:-public}"

if [ "${check_only}" = "true" ]; then
  exit 0
fi

exec martin "$@"
