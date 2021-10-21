
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235322299956"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211021235322299956"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
