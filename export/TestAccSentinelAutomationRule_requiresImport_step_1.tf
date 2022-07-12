


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220712042739428313"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-220712042739428313"
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


resource "azurerm_sentinel_automation_rule" "test" {
  name                       = "b6a182cb-02e6-4a69-a2c6-6dad73ba7db8"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-220712042739428313"
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}


resource "azurerm_sentinel_automation_rule" "import" {
  name                       = azurerm_sentinel_automation_rule.test.name
  log_analytics_workspace_id = azurerm_sentinel_automation_rule.test.log_analytics_workspace_id
  display_name               = azurerm_sentinel_automation_rule.test.display_name
  order                      = azurerm_sentinel_automation_rule.test.order
  action_incident {
    order = 1
  }
}
