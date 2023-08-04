
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-230804030624053360"
  location = "West Europe"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230804030624053360"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "free"
  replica_count       = 2
}
