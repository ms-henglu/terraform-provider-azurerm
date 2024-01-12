
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-240112035102288836"
  location = "westus"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice240112035102288836"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "free"
  semantic_search_sku = "free"
}
