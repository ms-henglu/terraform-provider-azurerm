

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-211013071906786533"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-211013071906786533"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
}
