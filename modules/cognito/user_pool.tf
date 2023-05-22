locals {
  up_name = "cup-${var.region_name}-${var.solution_fqn}-${var.user_pool_name}"
}

resource aws_cognito_user_pool this {
  name = local.up_name
  tags = merge({Name = local.up_name}, local.module_common_tags)

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers = true
    require_symbols = false
    temporary_password_validity_days = 7
  }

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }


}