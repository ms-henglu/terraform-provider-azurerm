

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-210924011432394877"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-210924011432394877"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}


resource "azurerm_sentinel_alert_rule_ms_security_incident" "test" {
  name                        = "acctest-SentinelAlertRule-MSI-210924011432394877"
  log_analytics_workspace_id  = azurerm_log_analytics_solution.test.workspace_resource_id
  product_filter              = "Microsoft Cloud App Security"
  display_name                = "some rule"
  severity_filter             = ["High"]
  display_name_filter         = ["alert1"]
  display_name_exclude_filter = ["alert3"]
}
