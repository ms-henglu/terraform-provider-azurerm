
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055740870615"
  location = "West Europe"
}

resource "azurerm_route_filter" "test" {
  name                = "acctestrf210928055740870615"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

}
