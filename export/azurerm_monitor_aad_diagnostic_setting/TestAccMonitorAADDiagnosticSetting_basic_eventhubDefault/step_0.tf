
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041503942253"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-231020041503942253"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "example"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  listen              = true
  send                = true
  manage              = true
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name                           = "acctest-DS-231020041503942253"
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.test.id
  enabled_log {
    category = "SignInLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "RiskyUsers"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "UserRiskEvents"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "B2CRequestLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
}
