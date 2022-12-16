
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013310117476"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-221216013310117476"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 333
    max_staleness_prefix    = 101101
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  geo_location {
    location          = "West US 2"
    failover_priority = 1
  }
}
