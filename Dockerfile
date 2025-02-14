#############
# Serve Nuxt in development mode.

FROM node:22.14.0-alpine@sha256:f93d93d31e202006196d5d22babb9bec7615b9a101744717df815d3d87e275f8 AS development

COPY ./docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN npm install -g corepack@latest \
  # TODO: remove (https://github.com/nodejs/corepack/issues/612)
  && corepack enable

WORKDIR /srv/app/

VOLUME /srv/.pnpm-store
VOLUME /srv/app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "dev"]

# Waiting for https://github.com/nuxt/framework/issues/6915
# HEALTHCHECK --interval=10s CMD wget -O /dev/null http://localhost:3000/api/healthcheck || exit 1


########################
# Prepare Nuxt.

FROM node:22.14.0-alpine@sha256:f93d93d31e202006196d5d22babb9bec7615b9a101744717df815d3d87e275f8 AS prepare

# The `CI` environment variable must be set for pnpm to run in headless mode
ENV CI=true

WORKDIR /srv/app/

COPY ./pnpm-lock.yaml package.json ./

RUN npm install -g corepack@latest \
    # TODO: remove (https://github.com/nodejs/corepack/issues/612)
    && corepack enable \
    && pnpm fetch

COPY ./ ./

RUN pnpm install --offline


########################
# Build Nuxt.

FROM node:22.14.0-alpine@sha256:f93d93d31e202006196d5d22babb9bec7615b9a101744717df815d3d87e275f8 AS build

ARG NUXT_PUBLIC_STACK_DOMAIN=jonas-thelemann.de
ENV NUXT_PUBLIC_STACK_DOMAIN=${NUXT_PUBLIC_STACK_DOMAIN}

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

ENV NODE_ENV=production
RUN npm install -g corepack@latest \
    # TODO: remove (https://github.com/nodejs/corepack/issues/612)
    && corepack enable \
    && pnpm --dir src run generate


########################
# Nuxt: lint

FROM node:22.14.0-alpine@sha256:f93d93d31e202006196d5d22babb9bec7615b9a101744717df815d3d87e275f8 AS lint

WORKDIR /srv/app/

COPY --from=prepare /srv/app/ ./

RUN npm install -g corepack@latest \
    # TODO: remove (https://github.com/nodejs/corepack/issues/612)
    && corepack enable \
    && pnpm --dir src run lint


#######################
# Collect build, lint and test results.

FROM node:22.14.0-alpine@sha256:f93d93d31e202006196d5d22babb9bec7615b9a101744717df815d3d87e275f8 AS collect

WORKDIR /srv/app/

COPY --from=build /srv/app/src/.output ./.output
COPY --from=lint /srv/app/package.json /tmp/lint/package.json
