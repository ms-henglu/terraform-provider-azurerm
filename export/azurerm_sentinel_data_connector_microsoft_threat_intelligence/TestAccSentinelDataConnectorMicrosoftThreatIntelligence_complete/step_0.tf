

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240105064545668586"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240105064545668586"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_microsoft_threat_intelligence" "test" {
  name                                         = "acctest-DC-MTI-240105064545668586"
  log_analytics_workspace_id                   = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  tenant_id                                    = data.azurerm_client_config.test.tenant_id
  microsoft_emerging_threat_feed_lookback_date = "1970-01-01T00:00:00Z"
}
