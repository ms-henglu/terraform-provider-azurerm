
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030334089621"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsalhu8h"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-230804030334089621"
  storage_account_id = azurerm_storage_account.test.id
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
}
