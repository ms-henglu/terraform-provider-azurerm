
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014608629582"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211015014608629582"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
