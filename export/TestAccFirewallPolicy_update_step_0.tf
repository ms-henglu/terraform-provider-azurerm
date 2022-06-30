

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220630210841181577"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220630210841181577"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
