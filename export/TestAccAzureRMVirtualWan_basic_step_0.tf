
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054722428492"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221019054722428492"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
