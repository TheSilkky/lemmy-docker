#syntax=docker/dockerfile:1-labs

ARG RUST_VERSION=1.70.0
ARG ALPINE_VERSION=3.18
ARG PICTRS_VERSION

####################################################################################################
## ARM64 builder
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:aarch64-musl-stable-${RUST_VERSION} AS build-arm64

ARG PICTRS_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add aarch64-unknown-linux-musl

ADD --keep-git-dir=true https://git.asonix.dog/asonix/pict-rs.git#v${PICTRS_VERSION} /pict-rs

WORKDIR /pict-rs

RUN cargo build --target=aarch64-unknown-linux-musl --release

####################################################################################################
## AMD64 builder
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:x86_64-musl-stable-${RUST_VERSION} AS build-amd64

ARG PICTRS_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add x86_64-unknown-linux-musl

ADD --keep-git-dir=true https://git.asonix.dog/asonix/pict-rs.git#v${PICTRS_VERSION} /pict-rs

WORKDIR /pict-rs

RUN cargo build --target=x86_64-unknown-linux-musl --release

####################################################################################################
## Intermediate build stage 
####################################################################################################
FROM build-${TARGETARCH} AS build

ARG TARGETARCH

RUN set -ex; \
        case "${TARGETARCH}" in \
            arm64) target='aarch64-unknown-linux-musl' ;; \
            amd64) target='x86_64-unknown-linux-musl' ;; \
            *) exit 1 ;; \
        esac; \
        mv "/pict-rs/target/$target/release/pict-rs" /pict-rs/pict-rs

####################################################################################################
### Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION} 

ARG PORT=8080
ARG DATA_PATH=/var/lib/pict-rs

ENV PICTRS__SERVER__ADDRESS="0.0.0.0:${PORT}"
ENV PICTRS__REPO__PATH="${DATA_PATH}/sled"
ENV PICTRS__REPO__EXPORT_PATH="${DATA_PATH}/sled-exports"
ENV PICTRS__STORE__PATH="${DATA_PATH}/files"

RUN apk add --no-cache \
    ca-certificates \
    imagemagick \
    ffmpeg \
    exiftool

COPY --from=build --chmod=0755 /pict-rs/pict-rs /usr/local/bin
COPY root /

RUN adduser --disabled-password --gecos "" --no-create-home pictrs && \
    mkdir -p "${DATA_PATH}" && \
    chown -R pictrs:pictrs "${DATA_PATH}"

USER pictrs

CMD ["pict-rs", "run"]

EXPOSE ${PORT}

VOLUME ${DATA_PATH}

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://github.com/TheSilkky/lemmy-docker.git"
LABEL org.opencontainers.image.title="pict-rs"
LABEL org.opencontainers.image.description="A simple image host"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"