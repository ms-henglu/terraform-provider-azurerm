

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230316222243358551"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230316222243358551"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_microsoft_threat_intelligence" "test" {
  name                                         = "acctest-DC-MTI-230316222243358551"
  log_analytics_workspace_id                   = azurerm_log_analytics_workspace.test.id
  tenant_id                                    = data.azurerm_client_config.test.tenant_id
  microsoft_emerging_threat_feed_lookback_date = "1970-01-01T00:00:00Z"
  bing_safety_phishing_url_lookback_date       = "1970-01-01T00:00:00Z"

  depends_on = [
    azurerm_sentinel_log_analytics_workspace_onboarding.test
  ]
}
