
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015711416251"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230721015711416251"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
