
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "duj8yfytnyk8x1ugphio1nfper18gnsmkzfxhajt6"
  token_secret = "xbf8iiqvrzx92qq30mk0iwefqc1nw06d8g7pbdbqn"
}
