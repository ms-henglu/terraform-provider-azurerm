
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015015116822428"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211015015116822428"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211015015116822428"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_servicebus_subscription" "test" {
  name                = "acctestservicebussubscription-211015015116822428"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  topic_name          = "${azurerm_servicebus_topic.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  max_delivery_count  = 10
	forward_to = "${azurerm_servicebus_topic.forward_to.name}"

}



resource "azurerm_servicebus_topic" "forward_to" {
  name                = "acctestservicebustopic-forward_to-211015015116822428"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}


