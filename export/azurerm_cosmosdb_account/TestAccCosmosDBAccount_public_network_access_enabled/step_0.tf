
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230922060857839013"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                          = "acctest-ca-230922060857839013"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  offer_type                    = "Standard"
  kind                          = "MongoDB"
  public_network_access_enabled = true

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
}
