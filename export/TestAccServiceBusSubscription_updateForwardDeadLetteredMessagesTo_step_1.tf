
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020200363591"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211029020200363591"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211029020200363591"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_servicebus_subscription" "test" {
  name                = "_acctestservicebussubscription-211029020200363591_"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  topic_name          = "${azurerm_servicebus_topic.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  max_delivery_count  = 10
	forward_dead_lettered_messages_to = "${azurerm_servicebus_topic.forward_dl_messages_to.name}"

}



resource "azurerm_servicebus_topic" "forward_dl_messages_to" {
  name                = "acctestservicebustopic-forward_dl_messages_to-211029020200363591"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}


