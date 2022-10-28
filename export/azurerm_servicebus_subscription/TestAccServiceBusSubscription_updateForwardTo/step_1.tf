
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172758486916"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221028172758486916"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-221028172758486916"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-221028172758486916_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	forward_to = "${azurerm_servicebus_topic.forward_to.name}"

}





resource "azurerm_servicebus_topic" "forward_to" {
  name         = "acctestservicebustopic-forward_to-221028172758486916"
  namespace_id = azurerm_servicebus_namespace.test.id
}




