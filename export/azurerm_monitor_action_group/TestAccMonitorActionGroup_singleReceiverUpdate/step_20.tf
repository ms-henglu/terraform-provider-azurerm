
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024934281015"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acceptanceTestEventHubNamespace-230825024934281015"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "acceptanceTestEventHub"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230825024934281015"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  event_hub_receiver {
    name                    = "eventhub-test-action"
    event_hub_id            = azurerm_eventhub.test.id
    use_common_alert_schema = false
  }
}
