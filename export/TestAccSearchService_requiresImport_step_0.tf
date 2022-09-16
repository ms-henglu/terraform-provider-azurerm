
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011947029938"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice220916011947029938"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}
