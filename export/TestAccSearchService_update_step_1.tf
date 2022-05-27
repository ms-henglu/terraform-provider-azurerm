
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034632440635"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice220527034632440635"
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
