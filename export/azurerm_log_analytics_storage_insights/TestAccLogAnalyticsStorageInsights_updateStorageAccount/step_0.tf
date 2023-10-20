

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-231020041332946417"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231020041332946417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsadsj7mfa"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_log_analytics_storage_insights" "test" {
  name                = "acctest-LA-231020041332946417"
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id

  blob_container_names = ["wad-iis-logfiles"]
  table_names          = ["WADWindowsEventLogsTable", "LinuxSyslogVer2v0"]

  storage_account_id  = azurerm_storage_account.test.id
  storage_account_key = azurerm_storage_account.test.primary_access_key
}
