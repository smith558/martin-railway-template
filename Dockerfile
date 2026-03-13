FROM ghcr.io/maplibre/martin:1.3.0

COPY martin.yaml /etc/martin/martin.yaml

CMD ["martin", "--config", "/etc/martin/martin.yaml"]