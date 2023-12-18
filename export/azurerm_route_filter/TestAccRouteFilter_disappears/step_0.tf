
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256439821"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf231218072256439821"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
