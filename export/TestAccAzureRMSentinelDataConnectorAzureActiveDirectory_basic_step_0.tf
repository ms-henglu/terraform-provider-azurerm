

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-210825045220981512"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-210825045220981512"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_sentinel_data_connector_azure_active_directory" "test" {
  name                       = "accTestDC-210825045220981512"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}
