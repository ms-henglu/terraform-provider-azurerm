
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_setting" "test" {
  setting_name = "Sentinel"
  enabled      = "true"
}
