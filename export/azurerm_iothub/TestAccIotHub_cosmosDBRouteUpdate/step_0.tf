
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "iothub" {
  name     = "acctest-iothub-240112224622705455"
  location = "eastus"
}

resource "azurerm_resource_group" "endpoint" {
  name     = "acctest-iothub-db-240112224622705455"
  location = "eastus"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-240112224622705455"
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
  name                = "acctest-240112224622705455"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "acctest-240112224622705455"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition/id"
}

resource "azurerm_iothub" "test" {
  name                = "acc-240112224622705455"
  resource_group_name = azurerm_resource_group.iothub.name
  location            = azurerm_resource_group.iothub.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  
}

resource "azurerm_iothub_endpoint_cosmosdb_account" "test" {
  name                = "acct-240112224622705455"
  resource_group_name = azurerm_resource_group.endpoint.name
  iothub_id           = azurerm_iothub.test.id
  container_name      = azurerm_cosmosdb_sql_container.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  endpoint_uri        = azurerm_cosmosdb_account.test.endpoint
  primary_key         = azurerm_cosmosdb_account.test.primary_key
  secondary_key       = azurerm_cosmosdb_account.test.secondary_key
}

resource "azurerm_iothub_route" "test" {
  resource_group_name = azurerm_resource_group.iothub.name
  iothub_name         = azurerm_iothub.test.name
  name                = "acctest-240112224622705455"

  source         = "DeviceMessages"
  condition      = "true"
  endpoint_names = [azurerm_iothub_endpoint_cosmosdb_account.test.name]
  enabled        = false
  depends_on     = [azurerm_iothub_endpoint_cosmosdb_account.test]
}
