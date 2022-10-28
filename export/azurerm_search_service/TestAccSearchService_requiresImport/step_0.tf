
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172722901411"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice221028172722901411"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}
