

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230113181652312270"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-230113181652312270"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "sentinel" {
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


data "azurerm_client_config" "current" {}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "8fbac89d-82e3-4004-9277-4675a56e0fa9"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-230113181652312270-update"
  order                      = 2
  enabled                    = false
  expiration                 = "2023-02-13T18:16:52Z"

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
