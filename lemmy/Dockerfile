#syntax=docker/dockerfile:1-labs

ARG RUST_VERSION=1.74.0
ARG ALPINE_VERSION=3.18
ARG LEMMY_VERSION
ARG UID=911
ARG GID=911

###################################################################################################
## Get source code
####################################################################################################
FROM scratch AS source

ARG LEMMY_VERSION

ADD --keep-git-dir=true https://github.com/LemmyNet/lemmy.git#${LEMMY_VERSION} /lemmy

####################################################################################################
## AMD64 builder base
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:x86_64-musl-stable-${RUST_VERSION}-openssl3 AS base-amd64

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"
ENV PQ_LIB_DIR="/usr/local/musl/pq15/lib"

RUN apt update && apt install -y \
    --no-install-recommends \
    git

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add x86_64-unknown-linux-musl

#RUN cargo install cargo-chef

####################################################################################################
## ARM64 builder base
####################################################################################################
FROM --platform=${BUILDPLATFORM} blackdex/rust-musl:aarch64-musl-stable-${RUST_VERSION}-openssl3 AS base-arm64

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME="/root/.cargo"
ENV PQ_LIB_DIR="/usr/local/musl/pq15/lib"

RUN apt update && apt install -y \
    --no-install-recommends \
    git

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal && \
    rustup target add aarch64-unknown-linux-musl

#RUN cargo install cargo-chef

####################################################################################################
## Generate cargo-chef recipe
####################################################################################################
#FROM base-amd64 AS chef-prepare
#
#WORKDIR /lemmy
#
#COPY --from=source /lemmy ./
#
# UN cargo chef prepare --recipe-path recipe.json

####################################################################################################
## AMD64 builder
####################################################################################################
FROM base-amd64 AS build-amd64

WORKDIR /lemmy

# COPY --from=chef-prepare /lemmy/recipe.json ./
# RUN cargo chef cook --target=x86_64-unknown-linux-musl --release --recipe-path recipe.json

COPY --from=source /lemmy ./
RUN echo "pub const VERSION: &str = \"$(git describe --tag)\";" > crates/utils/src/version.rs && \
    cargo build --target=x86_64-unknown-linux-musl --release && \
    mv target/x86_64-unknown-linux-musl/release/lemmy_server ./lemmy

####################################################################################################
## ARM64 builder
####################################################################################################
FROM base-arm64 AS build-arm64

WORKDIR /lemmy

# COPY --from=chef-prepare /lemmy/recipe.json ./
# RUN cargo chef cook --target=aarch64-unknown-linux-musl --release --recipe-path recipe.json

COPY --from=source /lemmy ./
RUN echo "pub const VERSION: &str = \"$(git describe --tag)\";" > crates/utils/src/version.rs && \
    cargo build --target=aarch64-unknown-linux-musl --release && \
    mv target/aarch64-unknown-linux-musl/release/lemmy_server ./lemmy

####################################################################################################
## Get target binary
####################################################################################################
FROM build-${TARGETARCH} AS build

####################################################################################################
### Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION} 

ARG LEMMY_VERSION
ARG UID
ARG GID

ENV LEMMY_CONFIG_LOCATION="/etc/lemmy/lemmy.hjson"

RUN apk add --no-cache \
    ca-certificates

COPY --from=build --chmod=0755 /lemmy/lemmy /usr/local/bin

RUN addgroup -S -g ${GID} lemmy && \
    adduser -S -H -D -G lemmy -u ${UID} -g "" -s /sbin/nologin lemmy

USER lemmy

CMD ["lemmy"]

EXPOSE 8536

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://github.com/LemmyNet/lemmy.git"
LABEL org.opencontainers.image.version="${LEMMY_VERSION}"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"
LABEL org.opencontainers.image.title="Lemmy"
LABEL org.opencontainers.image.description="A link aggregator and forum for the fediverse"