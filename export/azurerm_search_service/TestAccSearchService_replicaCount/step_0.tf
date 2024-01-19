
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-240119025734946430"
  location = "West Europe"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice240119025734946430"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "basic"
  replica_count       = 3
}
