

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182314454084"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221124182314454084"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-221124182314454084"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-221124182314454084_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	
}


resource "azurerm_servicebus_subscription" "import" {
  name               = azurerm_servicebus_subscription.test.name
  topic_id           = azurerm_servicebus_subscription.test.topic_id
  max_delivery_count = azurerm_servicebus_subscription.test.max_delivery_count
}
