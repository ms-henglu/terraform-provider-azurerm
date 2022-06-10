
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610023052328359"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestlogs-220610023052328359"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_security_center_automation" "test" {
  name                = "acctestautomation-220610023052328359"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name

  scopes = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  ]

  action {
    type        = "loganalytics"
    resource_id = azurerm_log_analytics_workspace.test.id
  }

  source {
    event_source = "Alerts"
  }
}
