#!/bin/bash -xe
set -xe
sudo mkdir -p /usr/local/lib/systemd/system/rke2-agent.service.d
cat <<'INI' | sudo tee /usr/local/lib/systemd/system/rke2-agent.service.d/90-lambda-ulimits.conf
[Service]
LimitNOFILE=infinity
LimitMEMLOCK=infinity
INI
sudo systemctl daemon-reload
sudo systemctl restart rke2-agent
