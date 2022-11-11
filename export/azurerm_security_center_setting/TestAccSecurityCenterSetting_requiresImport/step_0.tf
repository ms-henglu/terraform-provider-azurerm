
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_setting" "test" {
  setting_name = "MCAS"
  enabled      = "true"
}
