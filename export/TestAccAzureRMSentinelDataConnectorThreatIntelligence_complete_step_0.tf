

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-211029020132472270"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211029020132472270"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_threat_intelligence" "test" {
  name                       = "accTestDC-211029020132472270"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  tenant_id                  = data.azurerm_client_config.test.tenant_id
}
