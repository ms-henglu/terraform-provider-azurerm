
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030905646262"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220415030905646262"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
