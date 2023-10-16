

provider "azurerm" {
  features {}
}

resource "azurerm_marketplace_agreement" "test" {
  publisher = "barracudanetworks"
  offer     = "barracuda-ng-firewall"
  plan      = "hourly"
}


resource "azurerm_marketplace_agreement" "import" {
  publisher = azurerm_marketplace_agreement.test.publisher
  offer     = azurerm_marketplace_agreement.test.offer
  plan      = azurerm_marketplace_agreement.test.plan
}
