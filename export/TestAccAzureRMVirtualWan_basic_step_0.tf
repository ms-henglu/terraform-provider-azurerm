
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044824894126"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220121044824894126"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
