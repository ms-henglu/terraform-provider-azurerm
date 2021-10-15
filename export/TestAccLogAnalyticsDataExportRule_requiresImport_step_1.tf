


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-211015014800540790"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211015014800540790"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsadswmpzx"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_log_analytics_data_export_rule" "test" {
  name                    = "acctest-der-211015014800540790"
  resource_group_name     = azurerm_resource_group.test.name
  workspace_resource_id   = azurerm_log_analytics_workspace.test.id
  destination_resource_id = azurerm_storage_account.test.id
  table_names             = ["Heartbeat"]
}


resource "azurerm_log_analytics_data_export_rule" "import" {
  name                    = azurerm_log_analytics_data_export_rule.test.name
  resource_group_name     = azurerm_resource_group.test.name
  workspace_resource_id   = azurerm_log_analytics_workspace.test.id
  destination_resource_id = azurerm_storage_account.test.id
  table_names             = ["Heartbeat"]
}
