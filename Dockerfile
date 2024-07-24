#############
# Serve Nuxt in development mode.

FROM node:20.16.0-alpine@sha256:1a8bc4dc4720f0eb2f68d1883fd09f939103bd6df3848e0ffdc919d7fbf4dee1 AS development

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

FROM node:20.16.0-alpine@sha256:1a8bc4dc4720f0eb2f68d1883fd09f939103bd6df3848e0ffdc919d7fbf4dee1 AS prepare

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

FROM node:20.16.0-alpine@sha256:1a8bc4dc4720f0eb2f68d1883fd09f939103bd6df3848e0ffdc919d7fbf4dee1 AS build

ARG NUXT_PUBLIC_STACK_DOMAIN=jonas-thelemann.de
ENV NUXT_PUBLIC_STACK_DOMAIN=${NUXT_PUBLIC_STACK_DOMAIN}

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

ENV NODE_ENV=production
RUN corepack enable && \
    pnpm --dir src run generate


########################
# Nuxt: lint

FROM node:20.16.0-alpine@sha256:1a8bc4dc4720f0eb2f68d1883fd09f939103bd6df3848e0ffdc919d7fbf4dee1 AS lint

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

RUN corepack enable && \
    pnpm --dir src run lint


#######################
# Collect build, lint and test results.

FROM node:20.16.0-alpine@sha256:1a8bc4dc4720f0eb2f68d1883fd09f939103bd6df3848e0ffdc919d7fbf4dee1 AS collect

WORKDIR /srv/app/

COPY --from=build /srv/app/src/.output ./.output
COPY --from=lint /srv/app/package.json /tmp/lint/package.json
