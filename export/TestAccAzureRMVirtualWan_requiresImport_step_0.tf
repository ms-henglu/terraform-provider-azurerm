
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034758977573"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220225034758977573"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
