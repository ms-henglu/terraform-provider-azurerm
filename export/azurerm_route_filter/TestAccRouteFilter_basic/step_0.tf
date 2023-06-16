
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616075211668473"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230616075211668473"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
