

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210924011019829497"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-210924011019829497"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
