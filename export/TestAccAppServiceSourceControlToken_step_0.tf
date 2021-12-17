
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "rc217xdzzbbiwwxyad4f8kntx1drj3akex3s6a6gp"
  token_secret = "fge7jygl64zpgmnj3og2kpf4uiui9s67iv34i330m"
}
