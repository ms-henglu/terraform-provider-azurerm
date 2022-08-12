
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015532297324"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220812015532297324"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
