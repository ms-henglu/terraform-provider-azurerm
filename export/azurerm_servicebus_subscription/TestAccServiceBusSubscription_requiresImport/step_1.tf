

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124023700680"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-240315124023700680"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-240315124023700680"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-240315124023700680_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	
}


resource "azurerm_servicebus_subscription" "import" {
  name               = azurerm_servicebus_subscription.test.name
  topic_id           = azurerm_servicebus_subscription.test.topic_id
  max_delivery_count = azurerm_servicebus_subscription.test.max_delivery_count
}
