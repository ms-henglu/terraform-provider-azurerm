
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-search-230804030624051405"
  location = "West Europe"
}


resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230804030624051405"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  local_authentication_enabled = false
  authentication_failure_mode  = "http401WithBearerChallenge"
}
