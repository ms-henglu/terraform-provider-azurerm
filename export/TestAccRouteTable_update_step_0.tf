
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034758947615"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220225034758947615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
