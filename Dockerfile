# Serve Angular
FROM teracy/angular-cli AS development

WORKDIR /app/

COPY ./ /app/

RUN yarn

# Build and compile Angular
FROM node AS build

WORKDIR /app/

COPY --from=development /app/ /app/

ARG env=production

RUN yarn run build --prod --configuration $env

# Get some self-signed certificates so that nginx does not error on start.
# The certificates are to be overwritten by a mount in production.
FROM paulczar/omgwtfssl AS certificates

ENV SSL_KEY dargstack-example.key
ENV SSL_CERT dargstack-example.crt

RUN generate-certs

# Only the compiled app, ready for production with Nginx
FROM nginx AS production

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY --from=certificates /certs/ /etc/nginx/cert/

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
