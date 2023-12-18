

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-231218072513889185"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231218072513889185"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_alert_rule_nrt" "test" {
  name                       = "acctest-SentinelAlertRule-NRT-231218072513889185"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "Complete Rule"
  description                = "Some Description"
  tactics                    = ["Collection", "CommandAndControl"]
  techniques                 = ["T1560", "T1123"]
  severity                   = "Low"
  enabled                    = false
  incident {
    create_incident_enabled = true
    grouping {
      enabled                 = true
      lookback_duration       = "P7D"
      reopen_closed_incidents = true
      entity_matching_method  = "Selected"
      by_entities             = ["Host"]
      by_alert_details        = ["DisplayName"]
      by_custom_details       = ["OperatingSystemType", "OperatingSystemName"]
    }
  }
  query                = "Heartbeat"
  suppression_enabled  = true
  suppression_duration = "PT40M"
  alert_details_override {
    description_format   = "Alert from {{Compute}}"
    display_name_format  = "Suspicious activity was made by {{ComputerIP}}"
    severity_column_name = "Computer"
    tactics_column_name  = "Computer"
    dynamic_property {
      name  = "AlertLink"
      value = "dcount_ResourceId"
    }
  }
  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "FullName"
      column_name = "Computer"
    }
  }
  sentinel_entity_mapping {
    column_name = "Category"
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
