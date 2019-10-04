# Serve Angular
FROM teracy/angular-cli AS serve

WORKDIR /app

COPY ./ /app/

RUN yarn

# Build and compile Angular
FROM node AS node

WORKDIR /app

COPY ./ /app/

RUN yarn

ARG env=production

RUN yarn run build --prod --configuration $env

# Only the compiled app, ready for production with Nginx
FROM nginx

COPY --from=node /app/dist/ /usr/share/nginx/html

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
