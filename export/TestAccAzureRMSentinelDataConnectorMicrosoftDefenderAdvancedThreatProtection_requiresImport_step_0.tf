

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-210825030157302232"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-210825030157302232"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "test" {
  name                       = "accTestDC-210825030157302232"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}
