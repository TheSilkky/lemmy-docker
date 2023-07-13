#syntax=docker/dockerfile:1-labs

ARG RUST_VERSION=1.70.0
ARG ALPINE_VERSION=3.18
ARG LEMMY_VERSION

####################################################################################################
## AMD64 builder base
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:x86_64-musl-stable-${RUST_VERSION} AS base-amd64

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add x86_64-unknown-linux-musl

RUN cargo install chef

####################################################################################################
## ARM64 builder base
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:aarch64-musl-stable-${RUST_VERSION} AS base-arm64

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add aarch64-unknown-linux-musl

RUN cargo install chef

####################################################################################################
## Get source code
####################################################################################################
FROM alpine:${ALPINE_VERSION} AS source

ARG LEMMY_VERSION

ADD --keep-git-dir=true https://github.com/LemmyNet/lemmy.git#${LEMMY_VERSION} /lemmy

####################################################################################################
## Generate cargo-chef recipe
####################################################################################################
FROM base-amd64 AS chef-prepare

WORKDIR /lemmy

COPY --from=source /lemmy ./

RUN cargo chef prepare --recipe-path recipe.json

####################################################################################################
## AMD64 builder
####################################################################################################
FROM base-amd64 AS build-amd64

WORKDIR /lemmy

COPY --from=chef-prepare /lemmy/recipe.json ./
RUN cargo chef cook --target=x86_64-unknown-linux-musl --release --recipe-path recipe.json

COPY --from=source /lemmy ./
RUN echo "pub const VERSION: &str = \"$(git describe --tag)\";" > crates/utils/src/version.rs && \
    cargo build --target=x86_64-unknown-linux-musl --release

####################################################################################################
## ARM64 builder
####################################################################################################
FROM base-arm64 AS build-arm64

WORKDIR /lemmy

COPY --from=chef-prepare /lemmy/recipe.json ./
RUN cargo chef cook --target=aarch64-unknown-linux-musl --release --recipe-path recipe.json

COPY --from=source /lemmy ./
RUN echo "pub const VERSION: &str = \"$(git describe --tag)\";" > crates/utils/src/version.rs && \
    cargo build --target=aarch64-unknown-linux-musl --release

####################################################################################################
## Move binary
####################################################################################################
FROM build-${TARGETARCH} AS build

ARG TARGETARCH

RUN set -ex; \
        case "${TARGETARCH}" in \
            arm64) target='aarch64-unknown-linux-musl' ;; \
            amd64) target='x86_64-unknown-linux-musl' ;; \
            *) exit 1 ;; \
        esac; \
        mv "/lemmy/target/$target/release/lemmy_server" /lemmy/lemmy

####################################################################################################
### Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION} 

ARG CONFIG_DIR=/usr/local/etc/lemmy

ENV LEMMY_CONFIG_LOCATION="${CONFIG_DIR}/lemmy.hjson"

RUN apk add --no-cache \
    ca-certificates \
    gettext-envsubst

COPY --from=build --chmod=0755 /lemmy/lemmy /usr/local/bin
COPY --chmod=0755 entrypoint.sh /

RUN adduser --disabled-password --gecos "" --no-create-home lemmy && \
    mkdir -p "${CONFIG_DIR}" && \
    chown -R lemmy:lemmy "${CONFIG_DIR}"

USER lemmy

ENTRYPOINT ["/entrypoint.sh"]

CMD ["lemmy"]

EXPOSE 8536

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://github.com/TheSilkky/lemmy-docker.git"
LABEL org.opencontainers.image.title="Lemmy"
LABEL org.opencontainers.image.description="A link aggregator and forum for the fediverse"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"