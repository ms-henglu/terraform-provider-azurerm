
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "3hb6htoekugiu6tx9rdca0oz1agmw3bhsuyqmrqlc"
  token_secret = "99u0whui6mntuf0138dx9zsyp1bqql21rali00alv"
}
