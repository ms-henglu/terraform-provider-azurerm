

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230707010928820227"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-230707010928820227"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




data "azurerm_client_config" "current" {}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "73401cc6-453f-4a55-a4cd-e407db5da0b4"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "acctest-SentinelAutoRule-230707010928820227-update"
  order                      = 2
  enabled                    = false
  expiration                 = "2023-08-07T01:09:28Z"

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
