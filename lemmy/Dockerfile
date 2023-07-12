#syntax=docker/dockerfile:1-labs

ARG RUST_VERSION=1.70.0
ARG ALPINE_VERSION=3.18
ARG LEMMY_VERSION

####################################################################################################
## ARM64 builder
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:aarch64-musl-stable-${RUST_VERSION} AS build-arm64

ARG LEMMY_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add aarch64-unknown-linux-musl

ADD --keep-git-dir=true https://github.com/LemmyNet/lemmy.git#${LEMMY_VERSION} /lemmy

WORKDIR /lemmy

RUN cargo build --target=aarch64-unknown-linux-musl --release

####################################################################################################
## AMD64 builder
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:x86_64-musl-stable-${RUST_VERSION} AS build-amd64

ARG LEMMY_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add x86_64-unknown-linux-musl

ADD --keep-git-dir=true https://github.com/LemmyNet/lemmy.git#${LEMMY_VERSION} /lemmy

WORKDIR /lemmy

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
        mv "/lemmy/target/$target/release/lemmy_server" "/lemmy/lemmy"

####################################################################################################
### Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION} 

ARG CONFIG_LOCATION=/usr/local/etc/lemmy/lemmy.hjson

ENV LEMMY_CONFIG_LOCATION=${CONFIG_LOCATION}

RUN apk add --no-cache \
    ca-certificates

COPY --from=build --chmod=0755 /lemmy/lemmy /usr/local/bin/lemmy

RUN adduser --disabled-password --gecos "" --no-create-home lemmy && \
    mkdir -p /usr/local/etc/lemmy

USER lemmy

CMD ["lemmy"]

EXPOSE 8536

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://github.com/TheSilkky/lemmy-docker.git"
LABEL org.opencontainers.image.title="Lemmy"
LABEL org.opencontainers.image.description="A link aggregator and forum for the fediverse"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"