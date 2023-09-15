


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230915023830587047"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230915023830587047"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-230915023830587047"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct6ddmb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-LAW-230915023830587047"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-230915023830587047"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-EH-230915023830587047"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "acctestEHRule"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_mssql_server_extended_auditing_policy" "test" {
  server_id              = azurerm_mssql_server.test.id
  log_monitoring_enabled = true
}


resource "azurerm_monitor_diagnostic_setting" "test" {
  name                           = "acctest-DS-230915023830587047"
  target_resource_id             = azurerm_mssql_database.test.id
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.test.id
  eventhub_name                  = azurerm_eventhub.test.name


  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  // log, metric will return all disabled categories
  lifecycle {
    ignore_changes = [log, metric]
  }

}

resource "azurerm_mssql_database_extended_auditing_policy" "test" {
  database_id                = azurerm_mssql_database.test.id
  storage_endpoint           = azurerm_storage_account.test.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
  log_monitoring_enabled     = true
}
