
provider "azurerm" {
  features {}
}

resource "azurerm_security_center_auto_provisioning" "test" {
  auto_provision = "Off"
}
