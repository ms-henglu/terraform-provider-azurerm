
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "mtr2obnyzru6s08nhselugx9n9umhr3n6cmq0siui"
  token_secret = "w832nlfth1cmo0lf4q1iivp4rghh9uhkdq3k9i122"
}
