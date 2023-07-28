
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ocbl6v2zxtf0ujx094zz1q4a39irh2ie7vpuqww0v"
  token_secret = "bjr34pf4usonh3dl06p21prc00klvgvde6ns496tp"
}
