

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210910021430260393"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-210910021430260393"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
