

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220225034436033502"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220225034436033502"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
