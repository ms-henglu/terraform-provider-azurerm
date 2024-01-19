
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240119024752491914"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                 = "acctest-ca-240119024752491914"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.2"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableMongo16MBDocumentSupport"
  }
}
