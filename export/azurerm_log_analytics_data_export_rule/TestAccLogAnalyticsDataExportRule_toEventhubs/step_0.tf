

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-221222034907025537"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-221222034907025537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsadszvrsh"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctest-EHN-221222034907025537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctest-EH-221222034907025537"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 7
}


resource "azurerm_log_analytics_data_export_rule" "test" {
  name                    = "acctest-DER-221222034907025537"
  resource_group_name     = azurerm_resource_group.test.name
  workspace_resource_id   = azurerm_log_analytics_workspace.test.id
  destination_resource_id = azurerm_eventhub.test.id
  table_names             = ["Heartbeat"]
  enabled                 = true
}
