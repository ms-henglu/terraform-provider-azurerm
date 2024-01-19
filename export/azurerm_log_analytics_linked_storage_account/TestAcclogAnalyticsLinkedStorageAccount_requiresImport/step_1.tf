


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-240119025258336569"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240119025258336569"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsapxqmj1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_log_analytics_linked_storage_account" "test" {
  data_source_type      = "CustomLogs"
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  storage_account_ids   = [azurerm_storage_account.test.id]
}


resource "azurerm_log_analytics_linked_storage_account" "import" {
  data_source_type      = azurerm_log_analytics_linked_storage_account.test.data_source_type
  resource_group_name   = azurerm_log_analytics_linked_storage_account.test.resource_group_name
  workspace_resource_id = azurerm_log_analytics_linked_storage_account.test.workspace_resource_id
  storage_account_ids   = [azurerm_storage_account.test.id]
}
