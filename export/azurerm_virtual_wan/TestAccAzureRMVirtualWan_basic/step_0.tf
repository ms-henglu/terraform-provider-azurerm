
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012147243795"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230721012147243795"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
