

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-221111014212281054"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-workspace-221111014212281054"
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
  name                       = "57f0b164-363d-4df0-90b8-031db87f992d"
  log_analytics_workspace_id = azurerm_log_analytics_solution.sentinel.workspace_resource_id
  display_name               = "acctest-SentinelAutoRule-221111014212281054"
  order                      = 1

  action_incident {
    order  = 1
    status = "Active"
  }
}
