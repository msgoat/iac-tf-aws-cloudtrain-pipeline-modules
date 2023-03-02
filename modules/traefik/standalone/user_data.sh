#!/bin/bash

tee -a /data/traefik/config/config.yml <<'EOF'
http:

  services:
    nexus:
      loadBalancer:
        servers:
        - url: "http://10.31.1.204:8081"

  routers:
    nexus:
      rule: "Host(`nexus.cloudtrain.aws.msgoat.eu`)"
      service: "nexus"
      tls:
        certResolver: letsEncrypt
EOF