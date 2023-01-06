


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-230106031923142269"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230106031923142269"
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


resource "azurerm_sentinel_data_connector_office_irm" "test" {
  name                       = "accTestDC-230106031923142269"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  depends_on                 = [azurerm_log_analytics_solution.test]
}


resource "azurerm_sentinel_data_connector_office_irm" "import" {
  name                       = azurerm_sentinel_data_connector_office_irm.test.name
  log_analytics_workspace_id = azurerm_sentinel_data_connector_office_irm.test.log_analytics_workspace_id
}
