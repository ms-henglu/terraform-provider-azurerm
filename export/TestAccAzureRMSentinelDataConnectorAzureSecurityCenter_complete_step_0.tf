

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-211015015100604128"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211015015100604128"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_azure_security_center" "test" {
  name                       = "accTestDC-211015015100604128"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  subscription_id            = data.azurerm_client_config.test.subscription_id
}
