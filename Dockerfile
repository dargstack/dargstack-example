#############
# Serve Nuxt in development mode.

# Should be the specific version of `node:alpine`.
FROM node:19.8.1-alpine@sha256:f487fdae88463b8adba1cc82af1bc93058a4bc2f44c7c5c968958c6460d4c5c3 AS development

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
FROM node:19.8.1-alpine@sha256:f487fdae88463b8adba1cc82af1bc93058a4bc2f44c7c5c968958c6460d4c5c3 AS prepare

WORKDIR /srv/app/

COPY ./pnpm-lock.yaml ./

RUN corepack enable && \
    pnpm fetch

COPY ./ ./

RUN pnpm install --offline

########################
# Build Nuxt.

# Should be the specific version of `node:alpine`.
FROM node:19.8.1-alpine@sha256:f487fdae88463b8adba1cc82af1bc93058a4bc2f44c7c5c968958c6460d4c5c3 AS build

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
FROM node:19.8.1-alpine@sha256:f487fdae88463b8adba1cc82af1bc93058a4bc2f44c7c5c968958c6460d4c5c3 AS lint

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

RUN corepack enable && \
    pnpm run lint


#######################
# Collect build, lint and test results.

# Should be the specific version of `node:alpine`.
FROM node:19.8.1-alpine@sha256:f487fdae88463b8adba1cc82af1bc93058a4bc2f44c7c5c968958c6460d4c5c3 AS collect

WORKDIR /srv/app/

COPY --from=build /srv/app/.output ./.output
COPY --from=lint /srv/app/package.json /tmp/lint/package.json


#######################
# Provide a web server.

# Should be the specific version of `nginx:alpine`.
FROM nginx:1.23.3-alpine@sha256:6318314189b40e73145a48060bff4783a116c34cc7241532d0d94198fb2c9629 AS production

WORKDIR /usr/share/nginx/html

COPY ./docker/nginx.conf /etc/nginx/nginx.conf

COPY --from=collect /srv/app/.output/public/ ./

HEALTHCHECK --interval=10s CMD wget -O /dev/null http://localhost/api/healthcheck || exit 1
