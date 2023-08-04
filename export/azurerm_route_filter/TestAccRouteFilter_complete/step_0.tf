
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030421797423"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf230804030421797423"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
