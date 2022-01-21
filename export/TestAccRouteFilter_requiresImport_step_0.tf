
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044824880040"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf220121044824880040"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
