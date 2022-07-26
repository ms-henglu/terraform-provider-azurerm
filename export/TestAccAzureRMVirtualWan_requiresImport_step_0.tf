
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726002258544642"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220726002258544642"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
