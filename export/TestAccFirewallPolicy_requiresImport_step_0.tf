

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210924004314630052"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-210924004314630052"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
