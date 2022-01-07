
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034456226029"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220107034456226029"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-220107034456226029"
  namespace_id      = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name                = "_acctestservicebussubscription-220107034456226029_"
  topic_id          = azurerm_servicebus_topic.test.id
  max_delivery_count  = 10
	forward_to = "${azurerm_servicebus_topic.forward_to.name}"

}



resource "azurerm_servicebus_topic" "forward_to" {
  name                = "acctestservicebustopic-forward_to-220107034456226029"
  namespace_id      = azurerm_servicebus_namespace.test.id
}


