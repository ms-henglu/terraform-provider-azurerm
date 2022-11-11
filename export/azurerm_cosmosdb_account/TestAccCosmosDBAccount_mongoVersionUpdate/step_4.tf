
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-221111013314812284"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                 = "acctest-ca-221111013314812284"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.0"

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableMongo16MBDocumentSupport"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  lifecycle {
    ignore_changes = [
      capabilities
    ]
  }
}
