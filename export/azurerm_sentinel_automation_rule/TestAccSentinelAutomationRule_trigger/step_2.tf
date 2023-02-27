

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230227033354222195"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-230227033354222195"
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
  name                       = "e2756553-2787-48f7-a9b6-8d2dcd0f09d3"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-230227033354222195-update"
  order                      = 1
  condition_json = jsonencode([
    {
      conditionType = "PropertyChanged"
      conditionProperties = {
        propertyName   = "IncidentStatus"
        changeType     = "ChangedTo"
        operator       = "Equals"
        propertyValues = ["New"]
      }
    }
  ])

  triggers_when = "Updated"

  action_incident {
    order    = 1
    owner_id = data.azurerm_client_config.current.object_id
  }
}
