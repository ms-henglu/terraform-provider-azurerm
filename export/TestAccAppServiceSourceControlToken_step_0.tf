
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "gc2mhf4us78s48zoc0sg934yav4tgyks2tpqnl6o3"
  token_secret = "ze6h13e7uacuz34xf69ycrao9lndqre4ftpyudxd9"
}
