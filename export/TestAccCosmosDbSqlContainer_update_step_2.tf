


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-220124121914651990"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-220124121914651990"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "acctest-220124121914651990"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "acctest-CSQLC-220124121914651990"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition/id"
  unique_key {
    paths = ["/definition/id1", "/definition/id2"]
  }
  default_ttl = 1000
  throughput  = 400
  indexing_policy {
    indexing_mode = "Consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/testing/id2/*"
    }

    excluded_path {
      path = "/testing/id1/*"
    }

    composite_index {
      index {
        path  = "/path1"
        order = "Ascending"
      }
      index {
        path  = "/path2"
        order = "Descending"
      }
    }

    composite_index {
      index {
        path  = "/path3"
        order = "Ascending"
      }
      index {
        path  = "/path4"
        order = "Descending"
      }
    }
  }
}
