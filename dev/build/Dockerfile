# ====================
# --- Build Assets ---
# ====================
FROM node:16-alpine AS assets

RUN apk add yarn g++ make cmake python3 --no-cache

WORKDIR /wiki

COPY ./client ./client
COPY ./dev ./dev
COPY ./package.json ./package.json
COPY ./.babelrc ./.babelrc
COPY ./.eslintignore ./.eslintignore
COPY ./.eslintrc.yml ./.eslintrc.yml

RUN yarn cache clean
RUN yarn --frozen-lockfile --non-interactive
RUN yarn build
RUN rm -rf /wiki/node_modules
RUN yarn --production --frozen-lockfile --non-interactive

# ===============
# --- Release ---
# ===============
FROM node:16-alpine
LABEL maintainer="alexbmills5"

RUN apk add bash curl git openssh gnupg sqlite --no-cache && \
    mkdir -p /wiki && \
    mkdir -p /logs && \
    mkdir -p /wiki/data/content && \
    chown -R node:node /wiki /logs

WORKDIR /wiki

COPY --chown=node:node --from=assets /wiki/assets ./assets
COPY --chown=node:node --from=assets /wiki/node_modules ./node_modules
COPY --chown=node:node ./server ./server
COPY --chown=node:node --from=assets /wiki/server/views ./server/views
COPY --chown=node:node ./dev/build/config.yml ./config.yml
COPY --chown=node:node ./package.json ./package.json
COPY --chown=node:node ./LICENSE ./LICENSE

USER node

VOLUME ["/wiki/data/content"]

EXPOSE 3000
EXPOSE 3443

# HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 CMD curl -f http://localhost:3000/healthz

FROM golang:1.16.2-alpine3.13 as builder
WORKDIR /wiki
COPY . ./
# This is where one could build the application code as well.


FROM alpine:latest as tailscale
WORKDIR /wiki
ENV TSFILE=tailscale_1.42.0_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1


FROM alpine:latest
RUN apk update && apk add ca-certificates bash sudo && rm -rf /var/cache/apk/*

# Copy binary to production image
COPY --from=builder /wiki/start.sh /wiki/start.sh
COPY --from=tailscale /wiki/tailscaled /wiki/tailscaled
COPY --from=tailscale /wiki/tailscale /wiki/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
RUN chmod +x /wiki/start.sh

# Run node server
ENTRYPOINT ["node", "server"]

# Execute start.sh script
CMD ["/wiki/start.sh"]