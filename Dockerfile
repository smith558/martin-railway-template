FROM ghcr.io/maplibre/martin:1.3.1

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY martin.yaml /etc/martin/martin.yaml

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--config", "/etc/martin/martin.yaml"]
