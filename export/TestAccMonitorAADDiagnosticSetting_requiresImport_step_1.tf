

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623234031794985"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-220623234031794985"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-EH-220623234031794985"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
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
  name                           = "acctest-DS-220623234031794985"
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.test.id
  eventhub_name                  = azurerm_eventhub.test.name
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
    category = "NetworkAccessTrafficLogs"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "RiskyServicePrincipals"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "ServicePrincipalRiskEvents"
    enabled  = false
    retention_policy {}
  }
}


resource "azurerm_monitor_aad_diagnostic_setting" "import" {
  name                           = azurerm_monitor_aad_diagnostic_setting.test.name
  eventhub_authorization_rule_id = azurerm_monitor_aad_diagnostic_setting.test.eventhub_authorization_rule_id
  eventhub_name                  = azurerm_monitor_aad_diagnostic_setting.test.eventhub_name

  log {
    category = "SignInLogs"
    enabled  = true
    retention_policy {}
  }
  log {
    category = "NetworkAccessTrafficLogs"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "RiskyServicePrincipals"
    enabled  = false
    retention_policy {}
  }
  log {
    category = "ServicePrincipalRiskEvents"
    enabled  = false
    retention_policy {}
  }
}
