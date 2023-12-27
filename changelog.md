# Changelog
All notable changes to `iac-tf-aws-cloudtrain-pipeline-modules` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - YYYY-MM-DD
### Added
### Changed
### Fixed

## [1.3.1] - 2023-12-27
### Fixed
- Module harbor/standalone: fixed issue with s3 bucket after upgrade to current version of iac-tf-aws-cloudtrain-modules
- Module nexus/standalone: fixed issue with s3 bucket after upgrade to current version of iac-tf-aws-cloudtrain-modules

## [1.3.0] - 2023-12-21
### Changed
- Upgraded PostgreSQL version to 14.7
- Module traefik/standalone: fixed issue with dynamically retrieved AMI ID

## [1.2.0] - 2023-12-20
### Changed
- upgraded pipeline component modules will search for the latest AMI version now, if no AMI ID is specified

## [1.1.0] - 2023-11-30
### Changed
- upgraded all modules to AWS provider version 5
- improved documentation
- upgraded all CodeBuild projects to AWS manage build agent version 5.0 to support docker buildkit

## [1.0.0] - 2023-10-13
### Changed
- added proper module versioning through git tags
- added AWS CodeBuild support
