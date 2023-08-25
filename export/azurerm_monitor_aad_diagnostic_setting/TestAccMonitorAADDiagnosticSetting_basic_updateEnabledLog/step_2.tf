
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024934284875"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa9h2ju"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-230825024934284875"
  storage_account_id = azurerm_storage_account.test.id
  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
  enabled_log {
    category = "SignInLogs"
    retention_policy {
      enabled = true
      days    = 2
    }
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
}
