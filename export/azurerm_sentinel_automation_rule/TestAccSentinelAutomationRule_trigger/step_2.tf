

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240119025749573380"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-240119025749573380"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




data "azurerm_client_config" "current" {}

resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "7f5c148d-7ef8-421b-8175-bd264f11659f"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "acctest-SentinelAutoRule-240119025749573380-update"
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
