

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230120051745128098"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-cosmos-230120051745128098"
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
  name                = "acctestsqlrolenqqsb"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  type                = "CustomRole"
  assignable_scopes   = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.test.name}"]

  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read"]
  }
}


resource "azurerm_cosmosdb_sql_role_definition" "test2" {
  name                = "acctestsqlrole2nqqsb"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  type                = "CustomRole"
  assignable_scopes   = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.test.name}"]

  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*"]
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "test" {
  name                = "de906723-8e7b-448c-b6d0-296ed4ba60eb"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_cosmosdb_account.test.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.test2.id
  principal_id        = data.azurerm_client_config.current.object_id
  scope               = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.test.name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.test.name}"
}
