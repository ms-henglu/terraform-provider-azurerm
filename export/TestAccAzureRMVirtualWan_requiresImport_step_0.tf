
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044745667757"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211008044745667757"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
