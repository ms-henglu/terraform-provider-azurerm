

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-211001224027381021"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-211001224027381021"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
