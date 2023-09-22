


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230922060857873366"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230922060857873366"
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
  name                = "acctest-230922060857873366"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "acctest-CSQLC-230922060857873366"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition/id"

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/includedPath02/*"
    }

    excluded_path {
      path = "/excludedPath02/?"
    }

    composite_index {
      index {
        path  = "/path1"
        order = "ascending"
      }
      index {
        path  = "/path2"
        order = "descending"
      }
    }

    composite_index {
      index {
        path  = "/path3"
        order = "ascending"
      }
      index {
        path  = "/path4"
        order = "descending"
      }
    }

    spatial_index {
      path = "/path/*"
    }

    spatial_index {
      path = "/test/to/all/?"
    }
  }
}
