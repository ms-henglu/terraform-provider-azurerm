

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-231016034650008408"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016034650008408"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_office_365" "test" {
  name                       = "accTestDC-231016034650008408"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  tenant_id                  = data.azurerm_client_config.test.tenant_id
  exchange_enabled           = true
  sharepoint_enabled         = true
  teams_enabled              = true
}
