
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051223683047"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211119051223683047"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
