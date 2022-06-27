
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627130109782619"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220627130109782619"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
