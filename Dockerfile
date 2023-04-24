#############
# Serve Nuxt in development mode.

# Should be the specific version of `node:alpine`.
FROM node:20.0.0-alpine@sha256:2ffec31a58e85fbcd575c544a3584f6f4d128779e6b856153a04366b8dd01bb0 AS development

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

# Should be the specific version of `node:slim`.
FROM node:20.0.0-alpine@sha256:2ffec31a58e85fbcd575c544a3584f6f4d128779e6b856153a04366b8dd01bb0 AS prepare

WORKDIR /srv/app/

COPY ./pnpm-lock.yaml ./

RUN corepack enable && \
    pnpm fetch

COPY ./ ./

RUN pnpm install --offline

########################
# Build Nuxt.

# Should be the specific version of `node:alpine`.
FROM node:20.0.0-alpine@sha256:2ffec31a58e85fbcd575c544a3584f6f4d128779e6b856153a04366b8dd01bb0 AS build

ARG NUXT_PUBLIC_STACK_DOMAIN=jonas-thelemann.de
ENV NUXT_PUBLIC_STACK_DOMAIN=${NUXT_PUBLIC_STACK_DOMAIN}

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

ENV NODE_ENV=production
RUN corepack enable && \
    pnpm run generate


########################
# Nuxt: lint

# Should be the specific version of `node:alpine`.
FROM node:20.0.0-alpine@sha256:2ffec31a58e85fbcd575c544a3584f6f4d128779e6b856153a04366b8dd01bb0 AS lint

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

RUN corepack enable && \
    pnpm run lint


#######################
# Collect build, lint and test results.

# Should be the specific version of `node:alpine`.
FROM node:20.0.0-alpine@sha256:2ffec31a58e85fbcd575c544a3584f6f4d128779e6b856153a04366b8dd01bb0 AS collect

WORKDIR /srv/app/

COPY --from=build /srv/app/.output ./.output
COPY --from=lint /srv/app/package.json /tmp/lint/package.json
