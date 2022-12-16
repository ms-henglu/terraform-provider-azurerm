


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestsw221216014319350433"
  location = "West Europe"
}

resource "azurerm_storage_account" "sw" {
  name                     = "acctestswo8t79"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-221216014319350433"
  storage_account_id = azurerm_storage_account.sw.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw221216014319350433"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctesto8t79"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-LAW-221216014319350433"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-221216014319350433"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-EH-221216014319350433"
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


resource "azurerm_monitor_diagnostic_setting" "test" {
  name                       = "acctest-DS-221216014319350433"
  target_resource_id         = azurerm_synapse_workspace.test.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

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

resource "azurerm_synapse_workspace_extended_auditing_policy" "test" {
  synapse_workspace_id   = azurerm_synapse_workspace.test.id
  log_monitoring_enabled = true
}
