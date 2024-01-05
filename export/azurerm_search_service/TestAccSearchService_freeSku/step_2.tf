
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-240105061458145723"
  location = "westus"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice240105061458145723"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "free"
  semantic_search_sku = "free"
}
