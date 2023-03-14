module "postgresql" {
  # source = "../../../../iac-tf-aws-cloudtrain-modules//modules/database/postgresql/rds"
  source = "git::https://github.com/msgoat/iac-tf-aws-cloudtrain-modules.git//modules/database/postgresql/rds"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = local.module_common_tags
  postgresql_version = "14.6"
  db_instance_name = "sonarqube"
  db_database_name = "registry"
  vpc_id = data.aws_vpc.given.id
  db_subnet_ids = var.db_subnet_ids
  db_storage_type = "gp3"
  db_instance_class = "db.t4g.micro"
  db_min_storage_size = 20
  generate_url_friendly_password = true
  final_db_snapshot_enabled = var.final_snapshot_enabled
  db_snapshot_id = var.db_snapshot_id
}

