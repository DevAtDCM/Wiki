#!/bin/sh

/wiki/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
/wiki/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=azure-app
echo Tailscale started
ALL_PROXY=socks5://localhost:1055/ /wiki/