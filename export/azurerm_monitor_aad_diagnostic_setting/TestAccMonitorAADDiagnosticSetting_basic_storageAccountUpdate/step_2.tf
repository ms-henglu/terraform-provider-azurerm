
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423950572"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalur33"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-240119025423950572"
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
