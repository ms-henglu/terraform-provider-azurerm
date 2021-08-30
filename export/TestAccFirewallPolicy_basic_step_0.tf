

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210830084017480541"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-210830084017480541"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
