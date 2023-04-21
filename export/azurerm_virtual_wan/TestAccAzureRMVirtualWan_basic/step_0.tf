
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022629655374"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230421022629655374"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
