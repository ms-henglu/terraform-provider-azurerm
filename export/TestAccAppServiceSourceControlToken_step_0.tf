
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "b8ytfkwdbjndnd7uxklvprw3qbyf3odaq707pw8gv"
  token_secret = "9c6nyklkpv0lf62dof0nqsvg9kdj1jbguxa8midro"
}
