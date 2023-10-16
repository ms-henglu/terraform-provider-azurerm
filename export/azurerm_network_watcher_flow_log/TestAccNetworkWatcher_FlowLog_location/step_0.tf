

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-2310160359"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestNSG2310160359"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_watcher" "test" {
  name                = "acctest-NW-231016034431005659"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsa5659"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}


resource "azurerm_network_watcher_flow_log" "test" {
  network_watcher_name = azurerm_network_watcher.test.name
  resource_group_name  = azurerm_resource_group.test.name
  name                 = "flowlog-231016034431005659"
  location             = azurerm_resource_group.test.location

  network_security_group_id = azurerm_network_security_group.test.id
  storage_account_id        = azurerm_storage_account.test.id
  enabled                   = true

  retention_policy {
    enabled = false
    days    = 0
  }
}
