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

# Only the compiled app, ready for production with Nginx
FROM nginx AS production

COPY --from=build /app/dist/ /usr/share/nginx/html/

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
