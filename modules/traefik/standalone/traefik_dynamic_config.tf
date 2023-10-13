# traefik_dynamic_config.tf
# Generates the traefik dynamic configuration file with all backends and uploads it to S3

locals {
  traefik_dynamic_config = <<EOTPL
http:
  services:
%{ for be in local.traefik_backends ~}
    ${be.name}:
      loadBalancer:
        servers:
        - url: "${be.protocol}://${be.ec2_instance_private_ip}:${be.port}"
%{ endfor ~}
  routers:
%{ for be in local.traefik_backends ~}
    ${be.name}:
      rule: "Host(`${be.name}.${var.domain_name}`)"
      service: "${be.name}"
      tls:
        certResolver: letsEncrypt
%{ endfor ~}
EOTPL
}

data aws_s3_bucket shared {
  bucket = var.s3_bucket_traefik_config
}

resource aws_s3_object traefik {
  bucket = data.aws_s3_bucket.shared.bucket
  key = var.s3_object_traefik_config
  content = local.traefik_dynamic_config
  content_encoding = "UTF-8"
  content_type = "application/yaml"
  etag = md5(local.traefik_dynamic_config)
}