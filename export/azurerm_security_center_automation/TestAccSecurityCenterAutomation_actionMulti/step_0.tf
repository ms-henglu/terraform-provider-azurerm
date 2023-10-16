
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034644395957"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlogicapp-231016034644395957"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_logic_app_workflow" "test2" {
  name                = "acctestlogicapp2-231016034644395957"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_security_center_automation" "test" {
  name                = "acctestautomation-231016034644395957"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name

  scopes = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  ]

  action {
    type        = "logicapp"
    resource_id = azurerm_logic_app_workflow.test.id
    trigger_url = "https://example.net/this_is_never_validated_by_azure"
  }

  action {
    type        = "logicapp"
    resource_id = azurerm_logic_app_workflow.test2.id
    trigger_url = "https://example.net/this_is_also_never_validated_by_azure"
  }

  source {
    event_source = "Alerts"
  }
}
