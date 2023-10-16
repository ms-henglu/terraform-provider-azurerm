
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034326074674"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa7wo8t"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-231016034326074674"
  storage_account_id = azurerm_storage_account.test.id
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = true
      days    = 1
    }
  }
}
