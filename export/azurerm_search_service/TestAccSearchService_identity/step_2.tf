
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031909853155"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230106031909853155"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "staging"
  }
}
