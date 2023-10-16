
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700855168"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231016034700855168"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-231016034700855168"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-231016034700855168_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	
}
