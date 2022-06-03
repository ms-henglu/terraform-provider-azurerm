
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603022440168053"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220603022440168053"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
