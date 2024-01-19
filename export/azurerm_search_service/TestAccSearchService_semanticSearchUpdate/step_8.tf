
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-240119022755676751"
  location = "westus"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice240119022755676751"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
