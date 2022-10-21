
provider "azurerm" {
  features {}
}

resource "azurerm_marketplace_agreement" "test" {
  publisher = "barracudanetworks"
  offer     = "waf"
  plan      = "hourly"
}
