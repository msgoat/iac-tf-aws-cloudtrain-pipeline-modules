module s3_bucket {
  # source = "../../../../iac-tf-aws-cloudtrain-modules/modules/storage/blob"
  source = "git::https://github.com/msgoat/iac-tf-aws-cloudtrain-modules.git//modules/storage/blob"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  bucket_name = "harbor"
  deny_unencrypted_uploads = false
}