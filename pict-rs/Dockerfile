#syntax=docker/dockerfile:1-labs

ARG RUST_VERSION=1.71.0
ARG ALPINE_VERSION=3.18
ARG PICTRS_VERSION

####################################################################################################
## Get source code
####################################################################################################
FROM scratch AS source

ARG PICTRS_VERSION

ADD --keep-git-dir=true https://git.asonix.dog/asonix/pict-rs.git#v${PICTRS_VERSION} /pict-rs

####################################################################################################
## AMD64 builder base
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:x86_64-musl-stable-${RUST_VERSION} AS base-amd64

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add x86_64-unknown-linux-musl

#RUN cargo install cargo-chef

####################################################################################################
## ARM64 builder base
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:aarch64-musl-stable-${RUST_VERSION} AS base-arm64

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add aarch64-unknown-linux-musl

#RUN cargo install cargo-chef

####################################################################################################
## Generate cargo-chef recipe
####################################################################################################
#FROM base-amd64 AS chef-prepare
#
#WORKDIR /pict-rs
#
#COPY --from=source /pict-rs ./
#
#RUN cargo chef prepare --recipe-path recipe.json

####################################################################################################
## AMD64 builder
####################################################################################################
FROM base-amd64 AS build-amd64

WORKDIR /pict-rs

#COPY --from=chef-prepare /pict-rs/recipe.json ./
#RUN cargo chef cook --target=x86_64-unknown-linux-musl --release --recipe-path recipe.json

COPY --from=source /pict-rs ./
RUN cargo build --target=x86_64-unknown-linux-musl --release \
    && mv target/x86_64-unknown-linux-musl/release/pict-rs .

####################################################################################################
## ARM64 builder
####################################################################################################
FROM base-arm64 AS build-arm64

WORKDIR /pict-rs

#COPY --from=chef-prepare /pict-rs/recipe.json ./
#RUN cargo chef cook --target=aarch64-unknown-linux-musl --release --recipe-path recipe.json

COPY --from=source /pict-rs ./
RUN cargo build --target=aarch64-unknown-linux-musl --release \
    && mv target/aarch64-unknown-linux-musl/release/pict-rs .

####################################################################################################
## Get target binary
####################################################################################################
FROM build-${TARGETARCH} AS build

####################################################################################################
### Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION} 

ARG PICTRS_VERSION
ARG UID=911
ARG GID=911
ARG PORT=8080
ARG DATA_PATH=/var/lib/pict-rs

ENV PICTRS__SERVER__ADDRESS="0.0.0.0:${PORT}"
ENV PICTRS__REPO__PATH="${DATA_PATH}/sled"
ENV PICTRS__REPO__EXPORT_PATH="${DATA_PATH}/sled-exports"

RUN apk add --no-cache \
    ca-certificates \
    imagemagick \
    ffmpeg \
    exiftool

COPY --from=build --chmod=0755 /pict-rs/pict-rs /usr/local/bin
COPY root /

RUN addgroup -S -g ${GID} pictrs && \
    adduser -S -H -D -G pictrs -u ${UID} -g "" -s /sbin/nologin pictrs && \
    mkdir -p "${DATA_PATH}" && \
    chown -R pictrs:pictrs "${DATA_PATH}"

USER pictrs

CMD ["pict-rs", "run"]

EXPOSE ${PORT}

VOLUME ${DATA_PATH}

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://git.asonix.dog/asonix/pict-rs.git"
LABEL org.opencontainers.image.version=${PICTRS_VERSION}
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"
LABEL org.opencontainers.image.title="pict-rs"
LABEL org.opencontainers.image.description="A simple image host"