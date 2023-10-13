
provider "azurerm" {
  features {}
}

resource "azurerm_marketplace_agreement" "test" {
  publisher = "barracudanetworks"
  offer     = "barracuda-ng-firewall"
  plan      = "hourly"
}
