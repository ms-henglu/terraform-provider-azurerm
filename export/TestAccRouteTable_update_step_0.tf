
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045101537723"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210825045101537723"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
