
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015121277551"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220726015121277551"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
