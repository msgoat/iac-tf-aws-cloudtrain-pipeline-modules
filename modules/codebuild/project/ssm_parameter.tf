locals {
  parameter_names = [for p in var.project_parameters : p.name]
  parameters_by_name = zipmap(local.parameter_names, var.project_parameters)
}

resource aws_ssm_parameter this {
  for_each = local.parameters_by_name
  name = each.key
  type = "String"
  description = each.value.description
  value = each.value.value
  tags = merge({ Name = each.key }, local.module_common_tags)
}