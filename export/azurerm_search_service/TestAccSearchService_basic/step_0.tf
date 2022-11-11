
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014155888711"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice221111014155888711"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}
