#!/bin/bash

# apt-get update -y

# mkdir -p /etc/rancher/rke2

# echo "write-kubeconfig-mode: 644" > /etc/rancher/rke2/config.yaml
# echo "cloud-provider-name: aws" >> /etc/rancher/rke2/config.yaml
# echo "tls-san: " >> /etc/rancher/rke2/config.yaml
# echo "- ${cp_lb_host}" >> /etc/rancher/rke2/config.yaml

# curl -sfL https://get.rke2.io | sh -

# systemctl enable rke2-server
# systemctl start rke2-server

# sleep 5

# cp /etc/rancher/rke2/rke2.yaml /tmp/rke2.yaml
# sed -i -e "s/127.0.0.1/${cp_lb_host}/g"/tmp/rke2.yaml


