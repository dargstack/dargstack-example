#############
# Serve Nuxt in development mode.

FROM node:20.15.1-alpine@sha256:8b1984fab368a1b4e6972cf1f102d7879b242d5c255ec577ce98bbbd73d8571b AS development

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

FROM node:20.15.1-alpine@sha256:8b1984fab368a1b4e6972cf1f102d7879b242d5c255ec577ce98bbbd73d8571b AS prepare

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

FROM node:20.15.1-alpine@sha256:8b1984fab368a1b4e6972cf1f102d7879b242d5c255ec577ce98bbbd73d8571b AS build

ARG NUXT_PUBLIC_STACK_DOMAIN=jonas-thelemann.de
ENV NUXT_PUBLIC_STACK_DOMAIN=${NUXT_PUBLIC_STACK_DOMAIN}

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

ENV NODE_ENV=production
RUN corepack enable && \
    pnpm --dir src run generate


########################
# Nuxt: lint

FROM node:20.15.1-alpine@sha256:8b1984fab368a1b4e6972cf1f102d7879b242d5c255ec577ce98bbbd73d8571b AS lint

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

RUN corepack enable && \
    pnpm --dir src run lint


#######################
# Collect build, lint and test results.

FROM node:20.15.1-alpine@sha256:8b1984fab368a1b4e6972cf1f102d7879b242d5c255ec577ce98bbbd73d8571b AS collect

WORKDIR /srv/app/

COPY --from=build /srv/app/src/.output ./.output
COPY --from=lint /srv/app/package.json /tmp/lint/package.json
