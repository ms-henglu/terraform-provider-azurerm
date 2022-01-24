
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "islznvjxfrotxcx2zyn8wdmabd0zi4xk89ldkm83a"
  token_secret = "tu3pq8i3ul6cayc1zgddzih69gv9cotmi20urdjru"
}
