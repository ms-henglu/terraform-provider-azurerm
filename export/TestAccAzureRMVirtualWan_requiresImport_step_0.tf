
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024904064172"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211210024904064172"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
