
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040250107653"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211105040250107653"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
