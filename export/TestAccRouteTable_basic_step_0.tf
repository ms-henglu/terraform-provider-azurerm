
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128082747436763"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220128082747436763"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
