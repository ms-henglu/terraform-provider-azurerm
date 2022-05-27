

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-220527034645400021"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-220527034645400021"
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
  name                       = "2a46871a-6e4d-4d21-b0d9-055bfe794e8c"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-220527034645400021"
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}
