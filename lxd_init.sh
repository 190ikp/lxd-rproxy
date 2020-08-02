#!/usr/bin/env bash
set -euo pipefail

export PROXY_FQDN=$1
export STORAGE_DRIVER=zfs
export STORAGE_SOURCE=lxd-zpool

envsubst \$STORAGE_DRIVER\$STORAGE_SOURCE < conf/lxd/lxd_init.yaml |
  sudo lxd init --preseed

lxc launch ubuntu:18.04 proxy-container --profile proxy
lxc file push --quiet --recursive ../lxd_rproxy proxy-container/home/ubuntu/
lxc exec proxy-container -- sh -c \
  "sudo --login --user ubuntu bash -c \
    'sudo chown -R ubuntu:ubuntu ~/lxd_rproxy && \
    cd ~/lxd_rproxy && \
    ./proxy_init.sh $1'"