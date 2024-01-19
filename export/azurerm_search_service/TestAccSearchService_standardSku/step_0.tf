
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-240119025734947266"
  location = "West Europe"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice240119025734947266"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
