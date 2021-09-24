

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-210924004830244818"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-210924004830244818"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_sentinel_data_connector_azure_advanced_threat_protection" "test" {
  name                       = "accTestDC-210924004830244818"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}
