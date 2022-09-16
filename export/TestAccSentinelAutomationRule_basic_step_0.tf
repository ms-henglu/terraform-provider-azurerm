

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220916012000212207"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-220916012000212207"
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
  name                       = "ba1d2158-0a67-47f5-a1ed-82e456d96283"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-220916012000212207"
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}
