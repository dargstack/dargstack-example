# Serve Angular
FROM teracy/angular-cli AS development

WORKDIR /srv/app/

COPY ./ /srv/app/

RUN yarn

# Build and compile Angular
FROM node AS build

WORKDIR /srv/app/

COPY --from=development /srv/app/ /srv/app/

ARG env=production

RUN yarn run build --prod --configuration $env

# Only the compiled app, ready for production with Nginx
FROM nginx AS production

COPY --from=build /srv/app/dist/ /usr/share/nginx/html/

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
