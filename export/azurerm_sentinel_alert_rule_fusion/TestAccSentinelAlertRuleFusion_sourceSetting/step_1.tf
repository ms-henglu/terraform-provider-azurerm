

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240311033049052487"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240311033049052487"
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


data "azurerm_sentinel_alert_rule_template" "test" {
  display_name               = "Advanced Multistage Attack Detection"
  log_analytics_workspace_id = azurerm_log_analytics_solution.test.workspace_resource_id
}

resource "azurerm_sentinel_alert_rule_fusion" "test" {
  name                       = "acctest-SentinelAlertRule-Fusion-240311033049052487"
  log_analytics_workspace_id = azurerm_log_analytics_solution.test.workspace_resource_id
  alert_rule_template_guid   = data.azurerm_sentinel_alert_rule_template.test.name
  source {
    name    = "Anomalies"
    enabled = false
  }
  source {
    name    = "Alert providers"
    enabled = false
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Azure Active Directory Identity Protection"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Microsoft 365 Defender"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Microsoft Cloud App Security"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Azure Defender"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Microsoft Defender for Endpoint"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Microsoft Defender for Identity"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Azure Defender for IoT"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Microsoft Defender for Office 365"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Azure Sentinel scheduled analytics rules"
      enabled            = false
    }
    sub_type {
      severities_allowed = ["High", "Informational", "Low", "Medium"]
      name               = "Azure Sentinel NRT analytic rules"
      enabled            = false
    }
  }
}
