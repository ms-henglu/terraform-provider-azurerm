
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030045169351"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf210825030045169351"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
