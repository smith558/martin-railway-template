FROM ghcr.io/maplibre/martin:1.3.1

COPY martin.yaml /etc/martin/martin.yaml

CMD ["martin", "--config", "/etc/martin/martin.yaml"]