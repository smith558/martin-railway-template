FROM rust:1-trixie AS builder

ARG MARTIN_VERSION=martin-v1.3.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        clang \
        cmake \
        git \
        libfontconfig1-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libpq-dev \
        libsqlite3-dev \
        libssl-dev \
        nodejs \
        npm \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --depth 1 --branch "${MARTIN_VERSION}" https://github.com/maplibre/martin.git .

RUN cargo build --release --features=unstable-rendering

FROM debian:trixie-slim

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY martin.yaml /etc/martin/martin.yaml
COPY styles /etc/martin/styles

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-dejavu-core \
        libfontconfig1 \
        libfreetype6 \
        libjpeg62-turbo \
        libpng16-16 \
        libpq5 \
        libsqlite3-0 \
        libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/target/release/martin /usr/local/bin/martin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--config", "/etc/martin/martin.yaml"]
