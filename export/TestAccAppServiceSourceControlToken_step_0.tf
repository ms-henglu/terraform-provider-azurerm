
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "dqaco6r38mrizpy4gw8cgl2ge0xj7wjpmbxl2wo4l"
  token_secret = "g7q0y2u64vywobnbtu9fl48hrzjaot3a7m7n2q6o3"
}
