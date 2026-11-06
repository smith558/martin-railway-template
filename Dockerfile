ARG MARTIN_VERSION=1.16.1
FROM ghcr.io/maplibre/martin:${MARTIN_VERSION}

# The upstream Linux image includes rendering and its native dependencies.

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY styles /etc/martin/styles

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Railway assigns PORT dynamically; the upstream health check assumes 3000.
HEALTHCHECK CMD wget --spider "http://127.0.0.1:${PORT:-3000}/health" || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
