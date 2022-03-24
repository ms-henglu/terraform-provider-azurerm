

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220324163924541348"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-220324163924541348"
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


resource "azurerm_sentinel_alert_rule_scheduled" "test" {
  name                       = "acctest-SentinelAlertRule-Sche-220324163924541348"
  log_analytics_workspace_id = azurerm_log_analytics_solution.test.workspace_resource_id
  display_name               = "Complete Rule"
  description                = "Some Description"
  tactics                    = ["Collection", "CommandAndControl"]
  severity                   = "Low"
  enabled                    = false
  incident_configuration {
    create_incident = true
    grouping {
      enabled                 = true
      lookback_duration       = "P7D"
      reopen_closed_incidents = true
      entity_matching_method  = "Selected"
      group_by_entities       = ["Host"]
      group_by_alert_details  = ["DisplayName"]
      group_by_custom_details = ["OperatingSystemType", "OperatingSystemName"]
    }
  }
  query                = "Heartbeat"
  query_frequency      = "PT20M"
  query_period         = "PT40M"
  trigger_operator     = "Equal"
  trigger_threshold    = 5
  suppression_enabled  = true
  suppression_duration = "PT40M"
  alert_details_override {
    description_format   = "Alert from {{Compute}}"
    display_name_format  = "Suspicious activity was made by {{ComputerIP}}"
    severity_column_name = "Computer"
    tactics_column_name  = "Computer"
  }
  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "FullName"
      column_name = "Computer"
    }
  }
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "ComputerIP"
    }
  }
  custom_details = {
    OperatingSystemName = "OSName"
    OperatingSystemType = "OSType"
  }
}
