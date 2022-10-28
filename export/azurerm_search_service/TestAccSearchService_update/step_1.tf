
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172722903269"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice221028172722903269"
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
