
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024752494478"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-240119024752494478"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
