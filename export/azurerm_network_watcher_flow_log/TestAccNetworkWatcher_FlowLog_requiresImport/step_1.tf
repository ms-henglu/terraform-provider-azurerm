


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-2310130432"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestNSG2310130432"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_watcher" "test" {
  name                = "acctest-NW-231013043954314132"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsa314132"
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
  name                 = "flowlog-231013043954314132"

  network_security_group_id = azurerm_network_security_group.test.id
  storage_account_id        = azurerm_storage_account.test.id
  enabled                   = true

  retention_policy {
    enabled = false
    days    = 0
  }
}


resource "azurerm_network_watcher_flow_log" "import" {
  network_watcher_name = azurerm_network_watcher_flow_log.test.network_watcher_name
  resource_group_name  = azurerm_network_watcher_flow_log.test.resource_group_name
  name                 = azurerm_network_watcher_flow_log.test.name

  network_security_group_id = azurerm_network_watcher_flow_log.test.network_security_group_id
  storage_account_id        = azurerm_network_watcher_flow_log.test.storage_account_id
  enabled                   = azurerm_network_watcher_flow_log.test.enabled

  retention_policy {
    enabled = false
    days    = 0
  }
}
