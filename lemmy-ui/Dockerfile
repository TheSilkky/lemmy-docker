#syntax=docker/dockerfile:1-labs

ARG NODE_VERSION=20.4.0
ARG ALPINE_VERSION=3.18
ARG LEMMY_UI_VERSION

####################################################################################################
## Builder
####################################################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder

ARG LEMMY_UI_VERSION
ARG TARGETARCH

ENV npm_config_target_arch=${TARGETARCH}
ENV npm_config_target_platform=linux
ENV npm_config_target_libc=musl
ENV NODE_OPTIONS=--max_old_space_size=8192

RUN apk add --no-cache \
    build-base \
    git

ADD --keep-git-dir=true https://github.com/LemmyNet/lemmy-ui.git#${LEMMY_UI_VERSION} /tmp/lemmy-ui

WORKDIR /lemmy-ui

RUN cp /tmp/lemmy-ui/package.json /tmp/lemmy-ui/yarn.lock . && \
    yarn --production --prefer-offline --pure-lockfile

RUN cp -a /tmp/lemmy-ui/. . && rm -r /tmp/lemmy-ui && \
    echo "export const VERSION = '$(git describe --tag)';" > "src/shared/version.ts" && \
    yarn build:prod

####################################################################################################
## Final image
####################################################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

WORKDIR /lemmy-ui

COPY --from=builder /lemmy-ui/package.json /lemmy-ui/yarn.lock ./
COPY --from=builder /lemmy-ui/dist ./dist

RUN yarn install --production --prefer-offline --pure-lockfile && \
    yarn cache clean && \
    chown -R node:node /lemmy-ui

USER node

CMD ["node", "dist/js/server.js"]

EXPOSE 1234

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://github.com/TheSilkky/lemmy-docker.git"
LABEL org.opencontainers.image.title="Lemmy-UI"
LABEL org.opencontainers.image.description="The official web app for Lemmy, written in inferno."
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"