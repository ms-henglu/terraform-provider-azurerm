

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-211217075309384899"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-211217075309384899"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
