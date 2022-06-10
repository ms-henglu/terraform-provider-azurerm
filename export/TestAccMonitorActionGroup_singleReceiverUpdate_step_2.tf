
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022847335632"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-220610022847335632"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220610022847335632"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  itsm_receiver {
    name                 = "createorupdateticket"
    workspace_id         = "${data.azurerm_client_config.current.subscription_id}|${azurerm_log_analytics_workspace.test.workspace_id}"
    connection_id        = "53de6956-42b4-41ba-be3c-b154cdf17b13"
    ticket_configuration = "{}"
    region               = "eastus"
  }
}
