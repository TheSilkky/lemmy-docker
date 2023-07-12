ARG NODE_VERSION=20.4.0
ARG ALPINE_VERSION=3.18

####################################################################################################
## Builder
####################################################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder

ENV npm_config_target_platform=linux
ENV npm_config_target_libc=musl
ENV NODE_OPTIONS=--max_old_space_size=8192

RUN apk add --no-cache \
    build-base \
    git

WORKDIR /lemmy-ui

COPY lemmy-ui/package.json lemmy-ui/yarn.lock ./
RUN yarn install --production --prefer-offline

COPY lemmy-ui ./
RUN echo "export const VERSION = '$(git describe --tag)';" > "src/shared/version.ts" && \
    yarn build:prod

####################################################################################################
## Final image
####################################################################################################
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

WORKDIR /lemmy-ui

COPY lemmy-ui/package.json lemmy-ui/yarn.lock ./
COPY --from=builder /lemmy-ui/dist ./dist

RUN yarn install --production --prefer-offline && \
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