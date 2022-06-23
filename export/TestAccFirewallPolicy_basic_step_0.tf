

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220623223425798514"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220623223425798514"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
