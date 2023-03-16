

provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230316222243320152"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230316222243320152"
  location = "West Europe"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
}


data "azurerm_sentinel_alert_rule_anomaly" "test" {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  display_name               = "UEBA Anomalous Sign In"
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}

resource "azurerm_sentinel_alert_rule_anomaly_duplicate" "test" {
  display_name               = "acctest duplicate rule"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  built_in_rule_id           = data.azurerm_sentinel_alert_rule_anomaly.test.id
  enabled                    = true
  mode                       = "Flighting"

  threshold_observation {
    name  = "Anomaly score threshold"
    value = "0.6"
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.test]
}
