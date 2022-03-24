
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163655939744"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa8j2m9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-220324163655939744"
  storage_account_id = azurerm_storage_account.test.id
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
