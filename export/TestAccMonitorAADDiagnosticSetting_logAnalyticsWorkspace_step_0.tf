
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231226624726"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-LAW-220407231226624726"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name                       = "acctest-DS-220407231226624726"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  log {
    category = "SignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  log {
    category = "AuditLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  log {
    category = "NonInteractiveUserSignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  log {
    category = "ServicePrincipalSignInLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  log {
    category = "ManagedIdentitySignInLogs"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "ProvisioningLogs"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "ADFSSignInLogs"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "RiskyUsers"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  log {
    category = "UserRiskEvents"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 1
    }
  }
}
