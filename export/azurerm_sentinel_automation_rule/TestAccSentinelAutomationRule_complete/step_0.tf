

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-231218072513884271"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-231218072513884271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




data "azurerm_client_config" "current" {}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "025e5276-7801-4e62-ba30-1d965d53661b"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "acctest-SentinelAutoRule-231218072513884271-update"
  order                      = 2
  enabled                    = false
  expiration                 = "2024-01-18T07:25:13Z"

  condition_json = jsonencode(
    [
      {
        conditionProperties = {
          operator     = "Contains"
          propertyName = "IncidentTitle"
          propertyValues = [
            "a",
            "b",
          ]
        }
        conditionType = "Property"
      },
      {
        conditionProperties = {
          operator     = "Contains"
          propertyName = "IncidentTitle"
          propertyValues = [
            "c",
            "d",
          ]
        }
        conditionType = "Property"
      },
    ]
  )

  action_incident {
    order                  = 1
    status                 = "Closed"
    classification         = "BenignPositive_SuspiciousButExpected"
    classification_comment = "whatever reason"
  }

  action_incident {
    order  = 3
    labels = ["foo", "bar"]
  }

  action_incident {
    order    = 2
    severity = "High"
  }

  action_incident {
    order    = 4
    owner_id = data.azurerm_client_config.current.object_id
  }

}
