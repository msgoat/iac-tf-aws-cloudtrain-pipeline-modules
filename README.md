# Terraform Modules Library iac-tf-aws-cloudtrain-pipeline-modules

Collection of Terraform modules to provision CI/CD-pipelines on AWS using AWS CodeBuild etc.

## Module Versioning

This terraform multi-module is versioned via git tags. The main revision number according to semantic versioning
is stored in file [revision.txt](revision.txt). During the build further parts like branch name and short commit hash
are added to the tag name as well.

So if revision is `1.1.1` and the branch is `main` and the short commit hash is `12345678` the git tag name is `1.1.1.main.12345678`.

Whenever you want to pin the module version used in your terraform live code to a specific version
like `1.1.1.main.12345678`, add the corresponding tag name to the modules `source` attribute:

```text
module "eks_cluster" {
    source = "git::https://github.com/msgoat/iac-tf-aws-cloudtrain-pipeline-modules.git//modules/codebuild/project?ref=1.1.1.main.12345678"
}
```

## Release Information

A changelog can be found in [changelog.md](changelog.md).

## Status

![Build status](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiaW8zcXErR0d0RUZyU2hwSHNCek1qbnhvaUM5VkRsQTNVQmJrZVlrQnJxb2VIaWYwaTFlNTRyRHZlZS9hL0EwMk9ESVBZakNDWlBXVkd2aVlNeXFDZHo0PSIsIml2UGFyYW1ldGVyU3BlYyI6IkQrYUlpNjRGeFlrSXB6OXAiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)

## Provided Modules

| Module Name                                                      | Description |
|------------------------------------------------------------------| ----------- |
| [codebuild/project](modules/codebuild/project/README.md)         | Manages AWS CodeBuild projects backed by GitHub repositories. | 
| [harbor/standalone](modules/harbor/standalone/README.md)         | Manages [Harbor](https://goharbor.io/) as a standalone service hosted on a single EC2 instance. | 
| [keycloak/standalone](modules/keycloak/standalone/README.md)     | Manages [Keycloak](https://www.keycloak.org/) as a standalone service hosted on a single EC2 instance. | 
| [nexus/standalone](modules/nexus/standalone/README.md)           | Manages [Nexus OSS](https://www.sonatype.com/products/sonatype-nexus-oss) as a standalone service hosted on a single EC2 instance. | 
| [sonarqube/standalone](modules/sonarqube/standalone/README.md)   | Manages [SonarQube](https://www.sonarsource.com/products/sonarqube/) as a standalone service hosted on a single EC2 instance. | 
| [traefik/standalone](modules/traefik/standalone/README.md) | Manages [Traefik](https://doc.traefik.io/traefik/) as a standalone service hosted on a single EC2 instance. | 
