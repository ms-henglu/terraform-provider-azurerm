
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414022132207918"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230414022132207918"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230414022132207918"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-230414022132207918_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	dead_lettering_on_filter_evaluation_error = false

}
