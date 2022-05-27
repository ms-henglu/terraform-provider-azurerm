
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034437847565"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa8spo8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_monitor_log_profile" "test" {
  name = "acctestlp-220527034437847565"

  categories = [
    "Action",
  ]

  locations = [
    "West Europe",
  ]

  storage_account_id = azurerm_storage_account.test.id

  retention_policy {
    enabled = true
    days    = 7
  }
}
