

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220513180308635096"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220513180308635096"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
