
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034757510611"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-LAW-240112034757510611"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_data_factory" "test" {
  name                = "acctest-DF-240112034757510611"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_monitor_diagnostic_setting" "test" {
  name                       = "acctest-DS-240112034757510611"
  target_resource_id         = azurerm_data_factory.test.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  enabled_log {
    category = "ActivityRuns"
    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "PipelineRuns"
    retention_policy {
      enabled = false
      days    = 0
    }
  }

  enabled_log {
    category = "TriggerRuns"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SSISIntegrationRuntimeLogs"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SSISPackageEventMessageContext"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SSISPackageEventMessages"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SSISPackageExecutableStatistics"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SSISPackageExecutionComponentPhases"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SSISPackageExecutionDataStatistics"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SandboxActivityRuns"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  enabled_log {
    category = "SandboxPipelineRuns"
    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
