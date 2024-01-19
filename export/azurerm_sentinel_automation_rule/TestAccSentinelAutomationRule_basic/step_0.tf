

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-240119025749578918"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-240119025749578918"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}




resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "933d8850-ad61-43a7-bc66-66f042d52765"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
  display_name               = "acctest-SentinelAutoRule-240119025749578918"
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}
