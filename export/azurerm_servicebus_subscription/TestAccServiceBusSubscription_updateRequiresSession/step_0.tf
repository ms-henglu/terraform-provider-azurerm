
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035320766178"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221222035320766178"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-221222035320766178"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-221222035320766178_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	
}
