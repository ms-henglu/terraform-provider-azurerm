
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004346008521"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsakrsit"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_aad_diagnostic_setting" "test" {
  name               = "acctest-DS-230707004346008521"
  storage_account_id = azurerm_storage_account.test.id
  log {
    category = "SignInLogs"
    enabled  = false
    retention_policy {
      enabled = true
      days    = 1
    }
  }
}
