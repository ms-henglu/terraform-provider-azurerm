


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-231016034650004965"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016034650004965"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_data_connector_office_irm" "test" {
  name                       = "accTestDC-231016034650004965"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
}


resource "azurerm_sentinel_data_connector_office_irm" "import" {
  name                       = azurerm_sentinel_data_connector_office_irm.test.name
  log_analytics_workspace_id = azurerm_sentinel_data_connector_office_irm.test.log_analytics_workspace_id
}
