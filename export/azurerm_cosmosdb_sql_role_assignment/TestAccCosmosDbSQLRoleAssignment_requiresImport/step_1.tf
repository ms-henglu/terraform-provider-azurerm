


provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240112034129180473"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-cosmos-240112034129180473"
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
  name                = "acctestsqlrolehtnmd"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  type                = "CustomRole"
  assignable_scopes   = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.test.name}"]

  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read"]
  }
}


resource "azurerm_cosmosdb_sql_role_assignment" "test" {
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.test.id
  principal_id        = data.azurerm_client_config.current.object_id
  scope               = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.test.name}"
}


resource "azurerm_cosmosdb_sql_role_assignment" "import" {
  name                = azurerm_cosmosdb_sql_role_assignment.test.name
  resource_group_name = azurerm_cosmosdb_sql_role_assignment.test.resource_group_name
  account_name        = azurerm_cosmosdb_sql_role_assignment.test.account_name
  role_definition_id  = azurerm_cosmosdb_sql_role_assignment.test.role_definition_id
  principal_id        = azurerm_cosmosdb_sql_role_assignment.test.principal_id
  scope               = azurerm_cosmosdb_sql_role_assignment.test.scope
}
