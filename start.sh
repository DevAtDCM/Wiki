#!/bin/sh

/wiki/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
/wiki/tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=Wiki-Page
echo Tailscale started
#sudo ALL_PROXY=socks5://localhost:1055/ /wiki/my-app