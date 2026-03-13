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
    echo "warning: DATABASE_URL uses channel_binding=require. In testing, this caused Martin v1.3.1 to fail PostgreSQL startup. If Martin does not boot, try removing channel_binding=require from DATABASE_URL." >&2
    ;;
esac

export PORT="${PORT:-3000}"

if [ "${check_only}" = "true" ]; then
  exit 0
fi

exec martin "$@"
