

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-221111014212296158"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-221111014212296158"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
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


resource "azurerm_sentinel_data_connector_office_365_project" "test" {
  name                       = "accTestDC-221111014212296158"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  depends_on                 = [azurerm_log_analytics_solution.test]
}
