

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-240119025046825347"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-240119025046825347"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
