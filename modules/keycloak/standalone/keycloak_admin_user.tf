resource random_string admin_user {
  length = 16
  special = false
}

resource random_password admin_password {
  length = 25
  special = false
  override_special = "!#%&()-_=+[]{}:"
}