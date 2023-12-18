
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-231218072457700609"
  location = "westus"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice231218072457700609"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
  semantic_search_sku = "free"
}
