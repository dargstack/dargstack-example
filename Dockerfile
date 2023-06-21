#############
# Serve Nuxt in development mode.

FROM node:20.3.1-alpine@sha256:7a6e3b7dcc549a2af31be9dab80038e29e46df43c2e36f2a185e5239c45b9da2 AS development

COPY ./docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN corepack enable

WORKDIR /srv/app/

VOLUME /srv/.pnpm-store
VOLUME /srv/app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "dev"]

# Waiting for https://github.com/nuxt/framework/issues/6915
# HEALTHCHECK --interval=10s CMD wget -O /dev/null http://localhost:3000/api/healthcheck || exit 1


########################
# Prepare Nuxt.

FROM node:20.3.1-alpine@sha256:7a6e3b7dcc549a2af31be9dab80038e29e46df43c2e36f2a185e5239c45b9da2 AS prepare

# The `CI` environment variable must be set for pnpm to run in headless mode
ENV CI=true

WORKDIR /srv/app/

COPY ./pnpm-lock.yaml ./

RUN corepack enable && \
    pnpm fetch

COPY ./ ./

RUN pnpm install --offline


########################
# Build Nuxt.

FROM node:20.3.1-alpine@sha256:7a6e3b7dcc549a2af31be9dab80038e29e46df43c2e36f2a185e5239c45b9da2 AS build

ARG NUXT_PUBLIC_STACK_DOMAIN=jonas-thelemann.de
ENV NUXT_PUBLIC_STACK_DOMAIN=${NUXT_PUBLIC_STACK_DOMAIN}

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

ENV NODE_ENV=production
RUN corepack enable && \
    pnpm --dir nuxt run generate


########################
# Nuxt: lint

FROM node:20.3.1-alpine@sha256:7a6e3b7dcc549a2af31be9dab80038e29e46df43c2e36f2a185e5239c45b9da2 AS lint

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

RUN corepack enable && \
    pnpm --dir nuxt run lint


#######################
# Collect build, lint and test results.

FROM node:20.3.1-alpine@sha256:7a6e3b7dcc549a2af31be9dab80038e29e46df43c2e36f2a185e5239c45b9da2 AS collect

WORKDIR /srv/app/

COPY --from=build /srv/app/nuxt/.output ./.output
COPY --from=lint /srv/app/package.json /tmp/lint/package.json
