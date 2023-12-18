


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "iothub" {
  name     = "acctestRG-iothub-231218071922272889"
  location = "West Europe"
}

resource "azurerm_resource_group" "endpoint" {
  name     = "acctestRG-iothub-endpoint-231218071922272889"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-231218071922272889"
  location            = azurerm_resource_group.endpoint.location
  resource_group_name = azurerm_resource_group.endpoint.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.endpoint.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "acctest-231218071922272889"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "acctest-CSQLC-231218071922272889"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition/id"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-231218071922272889"
  resource_group_name = azurerm_resource_group.iothub.name
  location            = azurerm_resource_group.iothub.location
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-231218071922272889"
  resource_group_name = azurerm_resource_group.iothub.name
  location            = azurerm_resource_group.iothub.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}

resource "azurerm_cosmosdb_sql_role_definition" "test" {
  name                = "acctestsqlroled3l1w"
  resource_group_name = azurerm_resource_group.endpoint.name
  account_name        = azurerm_cosmosdb_account.test.name
  assignable_scopes = [
    azurerm_cosmosdb_account.test.id,
  ]

  permissions {
    data_actions = [
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
    ]
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "system" {
  resource_group_name = azurerm_resource_group.endpoint.name
  account_name        = azurerm_cosmosdb_account.test.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.test.id
  principal_id        = azurerm_iothub.test.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.test.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "user" {
  resource_group_name = azurerm_resource_group.endpoint.name
  account_name        = azurerm_cosmosdb_account.test.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.test.id
  principal_id        = azurerm_user_assigned_identity.test.principal_id
  scope               = azurerm_cosmosdb_account.test.id
}


resource "azurerm_iothub_endpoint_cosmosdb_account" "test" {
  name                = "acctest"
  resource_group_name = azurerm_resource_group.endpoint.name
  iothub_id           = azurerm_iothub.test.id
  container_name      = azurerm_cosmosdb_sql_container.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  endpoint_uri        = azurerm_cosmosdb_account.test.endpoint

  authentication_type = "identityBased"
  identity_id         = azurerm_user_assigned_identity.test.id

  depends_on = [
    azurerm_cosmosdb_sql_role_assignment.user,
  ]
}
