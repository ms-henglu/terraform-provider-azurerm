

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230721014812126913"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-cosmos-230721014812126913"
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


resource "azurerm_cosmosdb_sql_role_definition" "test" {
  role_definition_id  = "16e37992-6dbd-4fd9-a055-adb97acc8e54"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  name                = "acctestsqlrolee7je7"
  type                = "BuiltInRole"
  assignable_scopes   = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.test.name}/dbs/sales"]

  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read"]
  }
}
