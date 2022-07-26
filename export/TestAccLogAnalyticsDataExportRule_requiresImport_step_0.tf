

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-220726014952315375"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-220726014952315375"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsadssp7hu"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_log_analytics_data_export_rule" "test" {
  name                    = "acctest-DER-220726014952315375"
  resource_group_name     = azurerm_resource_group.test.name
  workspace_resource_id   = azurerm_log_analytics_workspace.test.id
  destination_resource_id = azurerm_storage_account.test.id
  table_names             = ["Heartbeat"]
}
