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

# ====================
# --- Build Tailscale Binaries ---
# ====================
FROM golang:1.16.2-alpine3.13 AS tailscale

WORKDIR /wiki

ENV TSFILE=tailscale_1.42.0_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
    tar xzf ${TSFILE} --strip-components=1

# ===============
# --- Release ---
# ===============
FROM node:16-alpine

LABEL maintainer="requarks.io"

RUN apk add bash curl git openssh gnupg sqlite --no-cache && \
    apk add netcat-openbsd && \
    apk add openssh openssh-keygen && echo "root:Docker!" | chpasswd && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /wiki && \
    mkdir -p /logs && \
    mkdir -p /etc/ssh && \
    mkdir -p /wiki/data/content && \
    mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale && \
    chown -R node:node /wiki /logs

WORKDIR /wiki

COPY --chown=node:node --from=assets /wiki/assets ./assets
COPY --chown=node:node --from=assets /wiki/node_modules ./node_modules
COPY --chown=node:node ./server ./server
COPY --chown=node:node --from=assets /wiki/server/views ./server/views
COPY --chown=node:node ./dev/build/config.yml ./config.yml
COPY --chown=node:node ./package.json ./package.json
COPY --chown=node:node ./LICENSE ./LICENSE
COPY --from=tailscale /wiki/tailscaled /wiki/tailscaled
COPY --from=tailscale /wiki/tailscale /wiki/tailscale
COPY /start.sh /start.sh

USER node

VOLUME ["/wiki/data/content"]

EXPOSE 3000 3443 80 2222

ENTRYPOINT ["node", "server"]

CMD ["/start.sh"]
