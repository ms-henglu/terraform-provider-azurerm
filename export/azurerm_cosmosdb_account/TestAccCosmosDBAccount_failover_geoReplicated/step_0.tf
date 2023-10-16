
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033649256832"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-231016033649256832"
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
