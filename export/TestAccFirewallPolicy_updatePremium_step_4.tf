

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220311032528901552"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220311032528901552"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
