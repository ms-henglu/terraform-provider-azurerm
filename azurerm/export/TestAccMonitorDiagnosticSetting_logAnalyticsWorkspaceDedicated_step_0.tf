
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627122849904724"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-LAW-220627122849904724"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_data_factory" "test" {
  name                = "acctest-DF-220627122849904724"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_monitor_diagnostic_setting" "test" {
  name                       = "acctest-DS-220627122849904724"
  target_resource_id         = azurerm_data_factory.test.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  log_analytics_destination_type = "Dedicated"

  log {
    category = "ActivityRuns"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "PipelineRuns"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "TriggerRuns"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SSISIntegrationRuntimeLogs"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SSISPackageEventMessageContext"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SSISPackageEventMessages"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SSISPackageExecutableStatistics"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SSISPackageExecutionComponentPhases"
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "SSISPackageExecutionDataStatistics"
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
}
