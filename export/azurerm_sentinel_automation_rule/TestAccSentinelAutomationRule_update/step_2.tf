

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230922061858812709"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-230922061858812709"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




data "azurerm_client_config" "current" {}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "b8f85c46-b474-42c8-8675-4ce336937b44"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "acctest-SentinelAutoRule-230922061858812709-update"
  order                      = 2
  enabled                    = false
  expiration                 = "2023-10-22T06:18:58Z"

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
