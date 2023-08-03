#syntax=docker/dockerfile:1-labs

ARG NODE_VERSION=20.4.0
ARG ALPINE_VERSION=3.18
ARG LEMMY_UI_VERSION

####################################################################################################
## Get source code
####################################################################################################
FROM scratch AS source

ARG LEMMY_UI_VERSION

ADD --keep-git-dir=true https://github.com/LemmyNet/lemmy-ui.git#${LEMMY_UI_VERSION} /lemmy-ui

####################################################################################################
## Builder
####################################################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder

ENV NODE_OPTIONS=--max_old_space_size=8192

RUN apk add --no-cache \
    git

WORKDIR /lemmy-ui

COPY --from=source /lemmy-ui/package.json /lemmy-ui/yarn.lock ./
RUN yarn --production --prefer-offline --pure-lockfile --network-timeout=1000000

COPY --from=source /lemmy-ui ./
RUN echo "export const VERSION = '$(git describe --tag)';" > "src/shared/version.ts" && \
    yarn build:prod

####################################################################################################
## Final image
####################################################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

ARG LEMMY_UI_VERSION
ARG UID=911
ARG GID=911

WORKDIR /opt/lemmy-ui

COPY --from=builder /lemmy-ui/node_modules ./node_modules
COPY --from=builder /lemmy-ui/dist ./dist

RUN addgroup -S -g ${GID} lemmy && \
    adduser -S -H -D -G lemmy -u ${UID} -g "" -s /sbin/nologin lemmy && \
    chown -R lemmy:lemmy /opt/lemmy-ui

USER lemmy

CMD ["node", "dist/js/server.js"]

EXPOSE 1234

STOPSIGNAL SIGTERM

LABEL org.opencontainers.image.source="https://github.com/TheSilkky/lemmy-docker.git"
LABEL org.opencontainers.image.version="${LEMMY_UI_VERSION}"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later"
LABEL org.opencontainers.image.title="Lemmy-UI"
LABEL org.opencontainers.image.description="The official web app for Lemmy, written in inferno."