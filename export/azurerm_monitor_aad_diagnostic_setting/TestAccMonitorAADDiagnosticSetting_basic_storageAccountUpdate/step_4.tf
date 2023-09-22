
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061531655848"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaql7rm"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-230922061531655848"
  storage_account_id = azurerm_storage_account.test.id
  enabled_log {
    category = "AuditLogs"
    retention_policy {}
  }
  enabled_log {
    category = "SignInLogs"
    retention_policy {}
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = false
      days    = 3
    }
  }
}
