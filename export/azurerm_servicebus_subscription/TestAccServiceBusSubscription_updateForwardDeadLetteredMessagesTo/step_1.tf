
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065649079356"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230929065649079356"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230929065649079356"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-230929065649079356_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	forward_dead_lettered_messages_to = "${azurerm_servicebus_topic.forward_dl_messages_to.name}"

}





resource "azurerm_servicebus_topic" "forward_dl_messages_to" {
  name         = "acctestservicebustopic-forward_dl_messages_to-230929065649079356"
  namespace_id = azurerm_servicebus_namespace.test.id
}




