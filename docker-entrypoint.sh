#!/bin/sh
set -eu

if [ -z "${DATABASE_URL:-}" ]; then
  echo "error: DATABASE_URL is required. Set DATABASE_URL or wire it from Railway, for example \${{PostGIS.DATABASE_URL}}." >&2
  exit 64
fi

exec martin "$@"
