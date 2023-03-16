# codebuild/project Terraform Module

Manages AWS CodeBuild projects backed by GitHub repositories.

For each CodeBuild project a webhook is created in GitHub which will trigger build whenever something is pushed to the corresponding GitHub repo.
Currently, only one branch - the `main` branch - is covered by CodeBuild.
In order to keep the number of S3 buckets at a minimum, all CodeBuild projects use the same S3 bucket as a build cache.
