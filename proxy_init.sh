#!/usr/bin/env bash
set -euxo pipefail

export PROXY_FQDN=$1

# Setting up nginx system user
sudo addgroup --system nginx
sudo adduser \
  --system \
  --disabled-login \
  --ingroup nginx \
  --no-create-home \
  --gecos "nginx system user" \
  --shell /bin/false \
  nginx

sudo apt update
sudo apt install --yes \
  curl \
  gnupg2 \
  ca-certificates \
  lsb-release

echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" |
  sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-key fingerprint ABF5BD827BD9BF62 |
  tr -s " " |
  grep "573B FD6B 3D8F BC64 1079 A6AB ABF5 BD82 7BD9 BF62"

sudo apt update
sudo apt install --yes nginx

envsubst \$PROXY_FQDN < conf/proxy/nginx.conf |
  sudo dd of=/etc/nginx/nginx.conf


# # Setting up nginx systemd service
# sudo cp conf/proxy/nginx.service /etc/systemd/system/nginx.service
# sudo chown root:root /etc/systemd/system/nginx.service
# sudo chmod 644 /etc/systemd/system/nginx,service

sudo systemctl enable nginx.service
sudo systemctl start nginx.service
