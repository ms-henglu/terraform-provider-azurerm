

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-211217075309386206"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-211217075309386206"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
