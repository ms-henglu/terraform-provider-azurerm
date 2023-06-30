
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033925846317"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230630033925846317"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230630033925846317"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name                                 = "_acctestservicebussubscription-230630033925846317_"
  topic_id                             = azurerm_servicebus_topic.test.id
  max_delivery_count                   = 10
  auto_delete_on_idle                  = "PT5M"
  lock_duration                        = "PT1M"
  dead_lettering_on_message_expiration = true
	
}


