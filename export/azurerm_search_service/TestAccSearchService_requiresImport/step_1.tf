

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-230526085805659548"
  location = "West Europe"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230526085805659548"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_search_service" "import" {
  name                = azurerm_search_service.test.name
  resource_group_name = azurerm_search_service.test.resource_group_name
  location            = azurerm_search_service.test.location
  sku                 = azurerm_search_service.test.sku
}
