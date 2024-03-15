
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240315122658346417"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test1" {
  name                = "acctest-ca-240315122658346417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableTable"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  backup {
    type = "Continuous"
  }
}

resource "azurerm_cosmosdb_table" "test" {
  name                = "acctest-sqltable-240315122658346417"
  resource_group_name = azurerm_cosmosdb_account.test1.resource_group_name
  account_name        = azurerm_cosmosdb_account.test1.name
}

resource "azurerm_cosmosdb_table" "test2" {
  name                = "acctest-sqltable2-240315122658346417"
  resource_group_name = azurerm_cosmosdb_account.test1.resource_group_name
  account_name        = azurerm_cosmosdb_account.test1.name

  depends_on = [azurerm_cosmosdb_table.test]
}

data "azurerm_cosmosdb_restorable_database_accounts" "test" {
  name     = azurerm_cosmosdb_account.test1.name
  location = azurerm_resource_group.test.location

  depends_on = [azurerm_cosmosdb_table.test2]
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca2-240315122658346417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableTable"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  backup {
    type = "Continuous"
  }

  create_mode = "Restore"

  restore {
    source_cosmosdb_account_id = data.azurerm_cosmosdb_restorable_database_accounts.test.accounts[0].id
    restore_timestamp_in_utc   = timeadd(timestamp(), "-1s")
    tables_to_restore          = [azurerm_cosmosdb_table.test.name, azurerm_cosmosdb_table.test2.name]
  }

  // As "restore_timestamp_in_utc" is retrieved dynamically, so it would cause diff when tf plan. So we have to ignore it here.
  lifecycle {
    ignore_changes = [
      restore.0.restore_timestamp_in_utc
    ]
  }
}
