
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045836085985"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230127045836085985"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
