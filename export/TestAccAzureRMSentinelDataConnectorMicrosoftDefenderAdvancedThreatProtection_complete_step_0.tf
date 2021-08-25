

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sentinel-210825045220983747"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-210825045220983747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}


data "azurerm_client_config" "test" {}

resource "azurerm_sentinel_data_connector_microsoft_defender_advanced_threat_protection" "test" {
  name                       = "accTestDC-210825045220983747"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  tenant_id                  = data.azurerm_client_config.test.tenant_id
}
