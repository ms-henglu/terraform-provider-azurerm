
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044907846265"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice211008044907846265"
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
