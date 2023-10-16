


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-231016034650003286"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016034650003286"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_data_connector_office_atp" "test" {
  name                       = "accTestDC-231016034650003286"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
}


resource "azurerm_sentinel_data_connector_office_atp" "import" {
  name                       = azurerm_sentinel_data_connector_office_atp.test.name
  log_analytics_workspace_id = azurerm_sentinel_data_connector_office_atp.test.log_analytics_workspace_id
}
