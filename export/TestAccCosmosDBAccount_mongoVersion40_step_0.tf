
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-211013071658616049"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                 = "acctest-ca-211013071658616049"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.0"

  capabilities {
    name = "EnableMongo"
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
