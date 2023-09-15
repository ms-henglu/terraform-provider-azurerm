

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024202397664"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctestacc2h66b"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "cosmos-sql-db"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "test" {
  name                = "test-container2h66b"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  database_name       = azurerm_cosmosdb_sql_database.test.name
  partition_key_path  = "/definition"
}

resource "azurerm_service_plan" "test" {
  location            = azurerm_resource_group.test.location
  name                = "testserviceplan2h66b"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "P1v2"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "test" {
  location            = azurerm_resource_group.test.location
  name                = "linuxwebapp2h66b"
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id
  site_config {}

  lifecycle {
    ignore_changes = [
      app_settings,
      identity,
      sticky_settings,
    ]
  }
}


resource "azurerm_app_service_connection" "test" {
  name               = "acctestserviceconnector230915024202397664"
  app_service_id     = azurerm_linux_web_app.test.id
  target_resource_id = azurerm_cosmosdb_sql_database.test.id
  authentication {
    type   = "secret"
    name   = "foo"
    secret = "bar"
  }
}
