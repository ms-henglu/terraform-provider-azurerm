
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031750884441"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230106031750884441"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
