
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044931124671"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice220121044931124671"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
  replica_count       = 2
  partition_count     = 3

  public_network_access_enabled = false

  tags = {
    environment = "Production"
    residential = "Area"
  }
}
