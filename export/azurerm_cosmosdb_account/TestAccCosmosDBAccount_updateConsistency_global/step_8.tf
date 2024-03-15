
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240315122658325975"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                    = "acctest-ca-240315122658325975"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  offer_type              = "Standard"
  kind                    = "GlobalDocumentDB"
  partition_merge_enabled = false

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 77
    max_staleness_prefix    = 700
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
