


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230414021037489445"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230414021037489445"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "BoundedStaleness"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_sql_dedicated_gateway" "test" {
  cosmosdb_account_id = azurerm_cosmosdb_account.test.id
  instance_size       = "Cosmos.D4s"
  instance_count      = 1
}


resource "azurerm_cosmosdb_sql_dedicated_gateway" "import" {
  cosmosdb_account_id = azurerm_cosmosdb_sql_dedicated_gateway.test.cosmosdb_account_id
  instance_count      = azurerm_cosmosdb_sql_dedicated_gateway.test.instance_count
  instance_size       = azurerm_cosmosdb_sql_dedicated_gateway.test.instance_size
}
