

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230526085826442422"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230526085826442422"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_threat_intelligence" "test" {
  name                       = "accTestDC-230526085826442422"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  tenant_id                  = data.azurerm_client_config.test.tenant_id
  lookback_date              = "1990-01-01T00:00:00Z"
}
