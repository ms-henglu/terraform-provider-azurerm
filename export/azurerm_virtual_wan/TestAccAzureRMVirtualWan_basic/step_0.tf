
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512004521367262"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230512004521367262"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
