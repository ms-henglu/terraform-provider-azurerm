

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-2112170755"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestNSG2112170755"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_watcher" "test" {
  name                = "acctest-NW-211217075627667255"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsa667255"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}


resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211217075627667255"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_network_watcher_flow_log" "test" {
  network_watcher_name = azurerm_network_watcher.test.name
  resource_group_name  = azurerm_resource_group.test.name

  network_security_group_id = azurerm_network_security_group.test.id
  storage_account_id        = azurerm_storage_account.test.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = false
    workspace_id          = azurerm_log_analytics_workspace.test.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.test.location
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
  }
}
