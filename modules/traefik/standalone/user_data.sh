#!/bin/bash

tee -a /data/traefik/config/config.yml <<'EOF'
http:

  services:
    nexus:
      loadBalancer:
        servers:
        - url: "http://nexus:8081"
    sonarqube:
      loadBalancer:
        servers:
        - url: "http://sonarqube:9000"

  routers:
    nexus:
      rule: "Host(`nexus.traefik.cloudtrain.aws.msgoat.eu`)"
      service: "nexus"
      tls:
        certResolver: letsEncrypt
      sonarqube:
        rule: "Host(`sonarqube.traefik.cloudtrain.aws.msgoat.eu`)"
        service: "sonarqube"
        tls:
          certResolver: letsEncrypt
EOF