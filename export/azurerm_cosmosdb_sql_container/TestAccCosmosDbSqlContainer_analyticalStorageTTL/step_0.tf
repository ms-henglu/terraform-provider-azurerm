

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230825024317967023"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230825024317967023"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  analytical_storage_enabled = true

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "acctest-230825024317967023"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                   = "acctest-CSQLC-230825024317967023"
  resource_group_name    = azurerm_cosmosdb_account.test.resource_group_name
  account_name           = azurerm_cosmosdb_account.test.name
  database_name          = azurerm_cosmosdb_sql_database.test.name
  partition_key_path     = "/definition/id"
  analytical_storage_ttl = 600
}
