
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031511223722"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211126031511223722"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
