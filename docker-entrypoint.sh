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
export MARTIN_WEB_UI="${MARTIN_WEB_UI:-disable}"
export MARTIN_PUBLISH_SCHEMA="${MARTIN_PUBLISH_SCHEMA:-public}"
export MARTIN_STYLE_RENDERING="${MARTIN_STYLE_RENDERING:-true}"

STYLE_TEMPLATE_DIR="/etc/martin/styles"
STYLE_RUNTIME_DIR="/tmp/martin-styles"
RUNTIME_CONFIG="/tmp/martin-runtime.yaml"

mkdir -p "${STYLE_RUNTIME_DIR}"

for template in "${STYLE_TEMPLATE_DIR}"/*.json; do
  [ -f "${template}" ] || continue
  target="${STYLE_RUNTIME_DIR}/$(basename "${template}")"
  sed "s/__PORT__/${PORT}/g" "${template}" > "${target}"
done

cat > "${RUNTIME_CONFIG}" <<EOF
listen_addresses: "0.0.0.0:${PORT}"
worker_processes: 4
cache_size_mb: 512
preferred_encoding: gzip
web_ui: ${MARTIN_WEB_UI}
on_invalid: abort

fonts: /usr/share/fonts/truetype/dejavu

styles:
  paths:
    - ${STYLE_RUNTIME_DIR}
  rendering: ${MARTIN_STYLE_RENDERING}

postgres:
  connection_string: ${DATABASE_URL}
  default_srid: 4326
  pool_size: 20
  auto_bounds: quick

  auto_publish:
    from_schemas:
      - ${MARTIN_PUBLISH_SCHEMA}
    tables:
      source_id_format: "{table}"
      clip_geom: true
      buffer: 64
      extent: 4096
    functions:
      source_id_format: "{schema}.{function}"
EOF

if [ "${check_only}" = "true" ]; then
  exit 0
fi

if [ "${1:-}" = "--config" ]; then
  shift 2
fi

exec martin --config "${RUNTIME_CONFIG}" "$@"
