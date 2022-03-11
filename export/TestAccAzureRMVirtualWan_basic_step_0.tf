
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311032915924036"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220311032915924036"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
