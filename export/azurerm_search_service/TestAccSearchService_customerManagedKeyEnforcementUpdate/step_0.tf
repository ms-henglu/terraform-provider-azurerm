
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-231016034636100121"
  location = "West Europe"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice231016034636100121"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
