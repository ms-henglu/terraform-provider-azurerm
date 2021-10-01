
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "4cr8pclerpcqvfnm0iw4s0kpwzygxhq7r3skj3qt9"
  token_secret = "k72m1fumzyvdv0qxvovedp9x0ahxv2yjug3loh9ju"
}
