

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220826003244940030"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-220826003244940030"
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
  name                       = "a4e6bee2-dc9a-4c14-a246-18c362364f4b"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-220826003244940030"
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}
