


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-221117231101701419"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-221117231101701419"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsadsok9du"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_log_analytics_storage_insights" "test" {
  name                = "acctest-la-221117231101701419"
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id

  storage_account_id  = azurerm_storage_account.test.id
  storage_account_key = azurerm_storage_account.test.primary_access_key
}


resource "azurerm_log_analytics_storage_insights" "import" {
  name                = azurerm_log_analytics_storage_insights.test.name
  resource_group_name = azurerm_log_analytics_storage_insights.test.resource_group_name
  workspace_id        = azurerm_log_analytics_storage_insights.test.workspace_id

  storage_account_id  = azurerm_storage_account.test.id
  storage_account_key = azurerm_storage_account.test.primary_access_key
}
