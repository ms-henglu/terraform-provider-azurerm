

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627132339667809"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220627132339667809"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-220627132339667809"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_servicebus_subscription" "test" {
  name                = "acctestservicebussubscription-220627132339667809"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  topic_name          = "${azurerm_servicebus_topic.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  max_delivery_count  = 10
	
}


resource "azurerm_servicebus_subscription" "import" {
  name                = azurerm_servicebus_subscription.test.name
  namespace_name      = azurerm_servicebus_subscription.test.namespace_name
  topic_name          = azurerm_servicebus_subscription.test.topic_name
  resource_group_name = azurerm_servicebus_subscription.test.resource_group_name
  max_delivery_count  = azurerm_servicebus_subscription.test.max_delivery_count
}
