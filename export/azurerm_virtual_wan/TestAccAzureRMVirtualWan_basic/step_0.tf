
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324052517283786"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230324052517283786"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
