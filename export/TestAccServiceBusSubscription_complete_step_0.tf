
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627124706097883"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220627124706097883"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-220627124706097883"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name                                 = "_acctestservicebussubscription-220627124706097883_"
  topic_id                             = azurerm_servicebus_topic.test.id
  max_delivery_count                   = 10
  auto_delete_on_idle                  = "PT5M"
  lock_duration                        = "PT1M"
  dead_lettering_on_message_expiration = true
	
}


