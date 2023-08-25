
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230825024317940824"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                       = "acctest-ca-230825024317940824"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  offer_type                 = "Standard"
  kind                       = "GlobalDocumentDB"
  analytical_storage_enabled = false

  analytical_storage {
    schema_type = "WellDefined"
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
