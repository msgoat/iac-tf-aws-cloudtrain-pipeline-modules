resource aws_cognito_user_group this {
  for_each = toset(var.groups)
  name = each.value
  user_pool_id = aws_cognito_user_pool.this.id
}