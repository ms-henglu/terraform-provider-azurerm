
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011308399640"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan210924011308399640"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
