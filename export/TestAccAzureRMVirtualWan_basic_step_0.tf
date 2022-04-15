
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030905643008"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220415030905643008"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
